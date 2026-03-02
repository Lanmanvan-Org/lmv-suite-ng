package core

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"gopkg.in/yaml.v3"
)

// ModuleManager handles module discovery, loading, and execution
type ModuleManager struct {
	ModulesDirs []string
	Modules     map[string]*ModuleConfig
}

func NewModuleManager(modulesDirs []string) *ModuleManager {
	return &ModuleManager{
		ModulesDirs: modulesDirs,
		Modules:     make(map[string]*ModuleConfig),
	}
}

func (mm *ModuleManager) DiscoverModules() error {
	for _, dir := range mm.ModulesDirs {
		if err := os.MkdirAll(dir, 0755); err != nil {
			return fmt.Errorf("cannot create modules directory %q: %w", dir, err)
		}

		if err := mm.discoverModulesRecursive(dir, ""); err != nil {
			return fmt.Errorf("module discovery failed in directory %q: %w", dir, err)
		}
	}
	return nil
}

func (mm *ModuleManager) discoverModulesRecursive(baseDir, namespace string) error {
	entries, err := os.ReadDir(baseDir)
	if err != nil {
		return fmt.Errorf("cannot read directory %q: %w", baseDir, err)
	}

	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}

		fullPath := filepath.Join(baseDir, entry.Name())
		qualifiedName := entry.Name()
		if namespace != "" {
			qualifiedName = namespace + "." + entry.Name()
		}

		if mm.isModuleDir(fullPath) {
			mm.loadModuleFromDir(fullPath, qualifiedName)
		} else {
			if err := mm.discoverModulesRecursive(fullPath, qualifiedName); err != nil {
				return err
			}
		}
	}
	return nil
}

func (mm *ModuleManager) isModuleDir(dir string) bool {
	// Fast path: module.yaml exists → it's a module
	if _, err := os.Stat(filepath.Join(dir, "module.yaml")); err == nil {
		return true
	}

	entries, err := os.ReadDir(dir)
	if err != nil {
		return false
	}

	for _, e := range entries {
		if !e.IsDir() && hasScriptExtension(e.Name()) {
			return true
		}
	}
	return false
}

func hasScriptExtension(name string) bool {
	return strings.HasSuffix(name, ".py") ||
		strings.HasSuffix(name, ".sh") ||
		strings.HasSuffix(name, ".rb") ||
		strings.HasSuffix(name, ".go")
}

func (mm *ModuleManager) loadModuleFromDir(dir, qualifiedName string) {
	cfg := &ModuleConfig{
		Path:   dir,
		Name:   qualifiedName,
		Loaded: false,
	}

	metaPath := filepath.Join(dir, "module.yaml")
	if _, err := os.Stat(metaPath); err == nil {
		meta, err := loadMetadata(metaPath)
		if err != nil {
			cfg.LoadError = fmt.Sprintf("invalid module.yaml in %q: %v", dir, err)
			mm.Modules[qualifiedName] = cfg
			return
		}
		cfg.Metadata = meta
		if meta.Type != "" {
			cfg.Type = meta.Type
		}
	}

	if cfg.Type == "" {
		cfg.Type = mm.inferModuleType(dir)
	}

	cfg.Loaded = true
	mm.Modules[qualifiedName] = cfg
}

func (mm *ModuleManager) inferModuleType(dir string) string {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return "unknown"
	}

	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		name := e.Name()
		switch {
		case strings.HasSuffix(name, ".py"):
			return "python"
		case strings.HasSuffix(name, ".sh"):
			return "bash"
		case strings.HasSuffix(name, ".rb"):
			return "ruby"
		case strings.HasSuffix(name, ".go"):
			return "go"
		}
	}
	return "unknown"
}

func (mm *ModuleManager) GetModule(name string) (*ModuleConfig, error) {
	mod, exists := mm.Modules[name]
	if !exists {
		return nil, fmt.Errorf("module %q not found – run DiscoverModules() first?", name)
	}
	if !mod.Loaded {
		if mod.LoadError != "" {
			return nil, fmt.Errorf("module %q failed to load: %s", name, mod.LoadError)
		}
		return nil, fmt.Errorf("module %q was discovered but not properly loaded (no type/entrypoint?)", name)
	}
	return mod, nil
}

func (mm *ModuleManager) ExecuteModule(moduleName string, args map[string]string) (*ExecutionResult, error) {
	mod, err := mm.GetModule(moduleName)
	if err != nil {
		return nil, err
	}

	switch mod.Type {
	case "python":
		return runScriptModule(mod, "python3", ".py", args)
	case "bash":
		return runScriptModule(mod, "bash", ".sh", args)
	case "ruby":
		return runScriptModule(mod, "ruby", ".rb", args)
	case "go":
		return &ExecutionResult{
			Timestamp: time.Now(),
			Success:   false,
			ExitCode:  1,
			Error:     "automatic execution of Go modules is not implemented – please build and run manually",
		}, nil
	default:
		return nil, fmt.Errorf("unsupported module type %q for module %q (supported: python, bash, ruby)", mod.Type, moduleName)
	}
}

// Unified runner for interpreted/script modules (python, bash, ruby)
func runScriptModule(mod *ModuleConfig, interpreter, ext string, args map[string]string) (*ExecutionResult, error) {
	result := &ExecutionResult{
		Timestamp: time.Now(),
	}

	script := findMainScript(mod.Path, ext)
	if script == "" {
		result.Success = false
		result.ExitCode = 127
		result.Error = fmt.Sprintf("no main script found in %q (looking for main%s)", mod.Path, ext)
		return result, nil
	}

	cmd := exec.Command(interpreter, script)
	cmd.Dir = mod.Path
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	env := os.Environ()
	for k, v := range args {
		env = append(env, fmt.Sprintf("ARG_%s=%s", strings.ToUpper(k), v))
	}
	cmd.Env = env

	err := cmd.Run()
	if err != nil {
		result.Success = false
		if exitErr, ok := err.(*exec.ExitError); ok {
			result.ExitCode = exitErr.ExitCode()
		} else {
			result.ExitCode = 1
		}
		result.Error = fmt.Sprintf("%s exited with error: %v", interpreter, err)
		return result, nil
	}

	result.Success = true
	result.ExitCode = 0
	return result, nil
}

func findMainScript(dir, ext string) string {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return ""
	}

	for _, e := range entries {
		if !e.IsDir() && e.Name() == "main"+ext {
			return filepath.Join(dir, e.Name())
		}
	}
	return ""
}

func loadMetadata(path string) (*ModuleMetadata, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("cannot read module.yaml: %w", err)
	}

	var meta ModuleMetadata
	if err := yaml.Unmarshal(data, &meta); err != nil {
		return nil, fmt.Errorf("cannot parse module.yaml: %w", err)
	}

	return &meta, nil
}

func (mm *ModuleManager) ListModules() []*ModuleConfig {
	loaded := make([]*ModuleConfig, 0, len(mm.Modules))
	for _, mod := range mm.Modules {
		if mod.Loaded {
			loaded = append(loaded, mod)
		}
	}
	return loaded
}
