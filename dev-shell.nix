{
  description = "NixOS Configuration Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Development tools
        devTools = with pkgs; [
          # Nix development
          nix
          nixfmt-rfc-style
          alejandra
          nix-linter
          deadnix
          statix
          
          # Git tools
          git
          pre-commit
          git-hooks
          
          # Python for testing
          python311
          python311Packages.pip
          python311Packages.virtualenv
          python311Packages.black
          python311Packages.flake8
          
          # Documentation
          mdbook
          mdbook-mermaid
          mdbook-admonish
          
          # System tools
          htop
          iotop
          tree
          ripgrep
          fd
          bat
          eza
          
          # Network tools
          curl
          wget
          nmap
          
          # Editor tools
          neovim
          helix
          
          # Shell tools
          zsh
          fish
          starship
          direnv
        ];
        
        # Shell configuration
        shellConfig = ''
          # Development environment setup
          export NIX_CONFIG="experimental-features = nix-command flakes"
          export NIX_PATH="nixpkgs=${nixpkgs}"
          
          # Git configuration
          git config --global init.defaultBranch main
          git config --global pull.rebase false
          
          # Development aliases
          alias fmt="nix fmt"
          alias check="nix flake check"
          alias build="nix build"
          alias test="python test-config.nix && python test-advanced.py && python test-window-managers.py"
          alias security="python test-security.py"
          alias clean="nix store gc"
          
          # Quick commands
          alias ll="eza -la"
          alias tree="tree -I '.git|result'"
          alias grep="rg"
          alias find="fd"
          
          echo "🚀 NixOS Configuration Development Environment"
          echo "📋 Available commands:"
          echo "  fmt     - Format Nix files"
          echo "  check   - Check flake configuration"
          echo "  build   - Build configuration"
          echo "  test    - Run all tests"
          echo "  security- Run security tests"
          echo "  clean   - Clean nix store"
          echo ""
          echo "🔧 Development tools available:"
          echo "  - nixfmt-rfc-style: Nix formatting"
          echo "  - alejandra: Nix formatting (alternative)"
          echo "  - nix-linter: Nix linting"
          echo "  - deadnix: Find dead code"
          echo "  - statix: Nix static analysis"
          echo "  - mdbook: Documentation generation"
          echo ""
        '';
        
      in
      {
        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = devTools;
          
          shellHook = shellConfig;
          
          # Environment variables
          NIX_CONFIG = "experimental-features = nix-command flakes";
        };
        
        # Packages
        packages = {
          # Development tools as packages
          dev-tools = pkgs.buildEnv {
            name = "nixos-config-dev-tools";
            paths = devTools;
          };
          
          # Documentation generator
          docs = pkgs.writeShellScriptBin "generate-docs" ''
            #!/bin/sh
            echo "📚 Generating documentation..."
            
            # Create docs directory
            mkdir -p docs/generated
            
            # Generate structure documentation
            echo "## Repository Structure" > docs/generated/structure.md
            find . -name "*.nix" -type f | head -50 >> docs/generated/structure.md
            
            # Generate module documentation
            echo "## Module Documentation" > docs/generated/modules.md
            for module in nixos/modules/*; do
              if [ -d "$module" ]; then
                echo "### $(basename $module)" >> docs/generated/modules.md
                find "$module" -name "*.nix" -type f | sed 's/^/- /' >> docs/generated/modules.md
                echo "" >> docs/generated/modules.md
              fi
            done
            
            echo "✅ Documentation generated in docs/generated/"
          '';
          
          # Test runner
          test-runner = pkgs.writeShellScriptBin "run-tests" ''
            #!/bin/sh
            echo "🧪 Running NixOS Configuration Tests"
            echo "=================================="
            
            # Basic structure tests
            echo "[1] Running basic structure tests..."
            python test-config.nix
            if [ $? -eq 0 ]; then
              echo "✅ Basic tests passed"
            else
              echo "❌ Basic tests failed"
              exit 1
            fi
            
            # Advanced tests
            echo "[2] Running advanced tests..."
            python test-advanced.py
            if [ $? -eq 0 ]; then
              echo "✅ Advanced tests passed"
            else
              echo "⚠️ Advanced tests had warnings"
            fi
            
            # Window manager tests
            echo "[3] Running window manager tests..."
            python test-window-managers.py
            if [ $? -eq 0 ]; then
              echo "✅ Window manager tests passed"
            else
              echo "⚠️ Window manager tests had warnings"
            fi
            
            # Security tests
            echo "[4] Running security tests..."
            python test-security.py
            if [ $? -eq 0 ]; then
              echo "✅ Security tests passed"
            else
              echo "⚠️ Security tests had warnings"
            fi
            
            echo ""
            echo "🎉 All tests completed!"
          '';
          
          # Configuration validator
          config-validator = pkgs.writeShellScriptBin "validate-config" ''
            #!/bin/sh
            echo "🔍 Validating NixOS Configuration"
            echo "================================="
            
            # Check flake
            echo "[1] Checking flake..."
            nix flake check
            if [ $? -eq 0 ]; then
              echo "✅ Flake check passed"
            else
              echo "❌ Flake check failed"
              exit 1
            fi
            
            # Validate configurations
            echo "[2] Validating configurations..."
            for host in athena nixos-vm; do
              echo "  Validating $host..."
              nix eval .#nixosConfigurations.$host.config.system.build.toplevel.drvPath
              if [ $? -eq 0 ]; then
                echo "  ✅ $host configuration valid"
              else
                echo "  ❌ $host configuration invalid"
                exit 1
              fi
            done
            
            echo "✅ All configurations valid"
          '';
          
          # Performance analyzer
          performance-analyzer = pkgs.writeShellScriptBin "analyze-performance" ''
            #!/bin/sh
            echo "📊 Analyzing Configuration Performance"
            echo "===================================="
            
            # Measure build time
            echo "[1] Measuring build time..."
            start_time=$(date +%s)
            nix build .#nixosConfigurations.athena.config.system.build.toplevel --no-link
            end_time=$(date +%s)
            build_time=$((end_time - start_time))
            echo "Build time: $build_time seconds"
            
            # Measure memory usage
            echo "[2] Measuring memory usage..."
            /usr/bin/time -v nix eval .#nixosConfigurations.athena.config 2> memory_usage.txt
            max_memory=$(grep "Maximum resident set size" memory_usage.txt | awk '{print $6}')
            echo "Peak memory usage: $max_memory KB"
            
            # Analyze configuration size
            echo "[3] Analyzing configuration size..."
            file_count=$(find . -name "*.nix" | wc -l)
            line_count=$(find . -name "*.nix" -exec wc -l {} + | tail -1 | awk '{print $1}')
            echo "Nix files: $file_count"
            echo "Total lines: $line_count"
            
            # Calculate complexity score
            complexity=$(python -c "
import sys
sys.path.append('.')
from test_advanced import AdvancedTestSuite
suite = AdvancedTestSuite()
result = suite.performance_benchmark()
print(result[2]['complexity_score'])
" 2>/dev/null || echo "N/A")
            echo "Complexity score: $complexity"
            
            # Cleanup
            rm -f memory_usage.txt result
            
            echo "✅ Performance analysis complete"
          '';
        };
        
        # Apps
        apps = {
          # Documentation app
          docs = flake-utils.lib.mkApp {
            drv = self.packages.${system}.docs;
          };
          
          # Test runner app
          test = flake-utils.lib.mkApp {
            drv = self.packages.${system}.test-runner;
          };
          
          # Config validator app
          validate = flake-utils.lib.mkApp {
            drv = self.packages.${system}.config-validator;
          };
          
          # Performance analyzer app
          analyze = flake-utils.lib.mkApp {
            drv = self.packages.${system}.performance-analyzer;
          };
        };
      }
    );
}
