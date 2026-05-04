#!/usr/bin/env python3
"""
Window Manager Integration Test Suite
Tests window manager configurations for completeness and functionality
"""

import os
import sys
import json
from pathlib import Path
from typing import Dict, List, Tuple, Any
from dataclasses import dataclass
from enum import Enum

class TestStatus(Enum):
    PASS = "PASS"
    FAIL = "FAIL"
    WARN = "WARN"

@dataclass
class WMTestResult:
    wm_name: str
    test_type: str
    status: TestStatus
    message: str
    details: Dict[str, Any] = None

class WindowManagerTestSuite:
    def __init__(self, config_path: str = "."):
        self.config_path = Path(config_path)
        self.results: List[WMTestResult] = []
    
    def test_wm_structure(self, wm_name: str) -> WMTestResult:
        """Test window manager directory structure"""
        wm_path = self.config_path / f"nixos/modules/desktop/window-managers/{wm_name}"
        
        required_structure = {
            "core": ["default.nix"],
            "packages": ["default.nix"],
            "config": ["default.nix"]
        }
        
        missing_items = []
        structure_details = {}
        
        for subdir, required_files in required_structure.items():
            subdir_path = wm_path / subdir
            if not subdir_path.exists():
                missing_items.append(f"Directory: {subdir}")
                continue
            
            structure_details[subdir] = {
                "exists": True,
                "files": []
            }
            
            for req_file in required_files:
                file_path = subdir_path / req_file
                if file_path.exists():
                    structure_details[subdir]["files"].append(req_file)
                else:
                    missing_items.append(f"File: {subdir}/{req_file}")
        
        # Check for additional files
        if wm_path.exists():
            all_files = []
            for file_path in wm_path.rglob("*.nix"):
                if file_path.is_file():
                    rel_path = file_path.relative_to(wm_path)
                    all_files.append(str(rel_path))
            
            structure_details["all_files"] = all_files
        
        status = TestStatus.FAIL if missing_items else TestStatus.PASS
        message = f"Structure {status.value.lower()}: {wm_name}"
        
        return WMTestResult(wm_name, "Structure", status, message, structure_details)
    
    def test_wm_config_completeness(self, wm_name: str) -> WMTestResult:
        """Test window manager configuration completeness"""
        config_path = self.config_path / f"nixos/modules/desktop/window-managers/{wm_name}/config"
        
        expected_configs = {
            "bspwm": ["theme.nix", "keybindings.nix", "autostart.nix"],
            "niri": ["theme.nix", "keybindings.nix", "autostart.nix"],
            "xfce": ["theme.nix", "panels.nix", "autostart.nix"]
        }
        
        if wm_name not in expected_configs:
            return WMTestResult(wm_name, "Config", TestStatus.WARN, f"Unknown WM: {wm_name}")
        
        missing_configs = []
        present_configs = []
        config_details = {}
        
        for config_file in expected_configs[wm_name]:
            file_path = config_path / config_file
            if file_path.exists():
                present_configs.append(config_file)
                # Analyze config content
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    config_details[config_file] = {
                        "size": len(content),
                        "lines": len(content.split('\n')),
                        "has_imports": "import" in content,
                        "has_packages": "environment.systemPackages" in content or "home.packages" in content
                    }
                except Exception as e:
                    config_details[config_file] = {"error": str(e)}
            else:
                missing_configs.append(config_file)
        
        status = TestStatus.FAIL if missing_configs else TestStatus.PASS
        message = f"Config {status.value.lower()}: {len(present_configs)}/{len(expected_configs[wm_name])} files"
        
        return WMTestResult(wm_name, "Config", status, message, {
            "present": present_configs,
            "missing": missing_configs,
            "details": config_details
        })
    
    def test_wm_packages(self, wm_name: str) -> WMTestResult:
        """Test window manager package definitions"""
        packages_path = self.config_path / f"nixos/modules/desktop/window-managers/{wm_name}/packages"
        
        if not packages_path.exists():
            return WMTestResult(wm_name, "Packages", TestStatus.FAIL, "Packages directory missing")
        
        package_files = list(packages_path.glob("*.nix"))
        package_details = {}
        total_packages = set()
        
        for pkg_file in package_files:
            if pkg_file.name == "default.nix":
                continue
            
            try:
                with open(pkg_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Extract package names (basic parsing)
                packages = []
                for line in content.split('\n'):
                    if 'with pkgs;' in line or 'with pkgs' in line:
                        continue
                    if line.strip().startswith('#') or not line.strip():
                        continue
                    # Simple package name extraction
                    if any(word in line for word in ['pkgs.', 'unstable.', 'nixpkgs.']):
                        # Extract package name after pkgs.
                        if 'pkgs.' in line:
                            pkg_name = line.split('pkgs.')[1].split()[0].rstrip(';')
                            packages.append(pkg_name)
                
                package_details[pkg_file.name] = {
                    "packages": packages,
                    "count": len(packages)
                }
                total_packages.update(packages)
                
            except Exception as e:
                package_details[pkg_file.name] = {"error": str(e)}
        
        status = TestStatus.PASS if package_files else TestStatus.WARN
        message = f"Packages {status.value.lower()}: {len(total_packages)} unique packages"
        
        return WMTestResult(wm_name, "Packages", status, message, {
            "files": [f.name for f in package_files if f.name != "default.nix"],
            "unique_packages": list(total_packages),
            "total_count": len(total_packages),
            "details": package_details
        })
    
    def test_wm_services(self, wm_name: str) -> WMTestResult:
        """Test window manager service definitions"""
        services_path = self.config_path / f"nixos/modules/desktop/window-managers/{wm_name}/services"
        
        if not services_path.exists():
            # Some WMs might not have services
            return WMTestResult(wm_name, "Services", TestStatus.WARN, "No services directory")
        
        service_files = list(services_path.glob("*.nix"))
        service_details = {}
        enabled_services = []
        
        for svc_file in service_files:
            if svc_file.name == "default.nix":
                continue
            
            try:
                with open(svc_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Extract service definitions
                services = []
                for line in content.split('\n'):
                    if 'services.' in line and '.enable' in line and '= true' in line:
                        # Extract service name
                        service_name = line.split('services.')[1].split('.')[0]
                        services.append(service_name)
                        enabled_services.append(service_name)
                
                service_details[svc_file.name] = {
                    "services": services,
                    "count": len(services)
                }
                
            except Exception as e:
                service_details[svc_file.name] = {"error": str(e)}
        
        status = TestStatus.PASS if service_files else TestStatus.WARN
        message = f"Services {status.value.lower()}: {len(enabled_services)} enabled services"
        
        return WMTestResult(wm_name, "Services", status, message, {
            "files": [f.name for f in service_files if f.name != "default.nix"],
            "enabled_services": enabled_services,
            "details": service_details
        })
    
    def test_wm_shared_integration(self, wm_name: str) -> WMTestResult:
        """Test integration with shared configurations"""
        wm_config_path = self.config_path / f"nixos/modules/desktop/window-managers/{wm_name}/config"
        shared_path = self.config_path / "nixos/modules/desktop/window-managers/shared"
        
        if not wm_config_path.exists() or not shared_path.exists():
            return WMTestResult(wm_name, "Integration", TestStatus.WARN, "Shared config missing")
        
        # Check if WM config imports shared config
        integration_details = {
            "shared_exists": shared_path.exists(),
            "shared_files": [],
            "wm_imports_shared": False
        }
        
        # Get shared files
        if shared_path.exists():
            integration_details["shared_files"] = [f.name for f in shared_path.glob("*.nix")]
        
        # Check WM config imports
        for config_file in wm_config_path.glob("*.nix"):
            try:
                with open(config_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                if '../shared' in content or '../../shared' in content:
                    integration_details["wm_imports_shared"] = True
                    break
            except:
                pass
        
        status = TestStatus.PASS if integration_details["wm_imports_shared"] else TestStatus.WARN
        message = f"Integration {status.value.lower()}: {'Uses shared' if integration_details['wm_imports_shared'] else 'No shared integration'}"
        
        return WMTestResult(wm_name, "Integration", status, message, integration_details)
    
    def run_wm_tests(self, wm_name: str):
        """Run all tests for a specific window manager"""
        print(f"\nTesting {wm_name.upper()} Window Manager")
        print("-" * 40)
        
        tests = [
            ("Structure", self.test_wm_structure),
            ("Configuration", self.test_wm_config_completeness),
            ("Packages", self.test_wm_packages),
            ("Services", self.test_wm_services),
            ("Integration", self.test_wm_shared_integration)
        ]
        
        for test_name, test_func in tests:
            result = test_func(wm_name)
            self.results.append(result)
            print(f"  {result.status.value}: {result.message}")
            
            # Show details for failures
            if result.status == TestStatus.FAIL and result.details:
                if "missing" in result.details:
                    for item in result.details["missing"][:3]:
                        print(f"    Missing: {item}")
    
    def run_all_tests(self):
        """Run tests for all window managers"""
        print("Window Manager Integration Test Suite")
        print("=" * 50)
        
        window_managers = ["bspwm", "niri", "xfce"]
        
        for wm in window_managers:
            self.run_wm_tests(wm)
        
        # Generate summary
        self.generate_summary()
    
    def generate_summary(self):
        """Generate test summary"""
        print("\n" + "=" * 50)
        print("WINDOW MANAGER TEST SUMMARY")
        print("=" * 50)
        
        # Group results by WM
        wm_results = {}
        for result in self.results:
            if result.wm_name not in wm_results:
                wm_results[result.wm_name] = []
            wm_results[result.wm_name].append(result)
        
        for wm_name, results in wm_results.items():
            print(f"\n{wm_name.upper()}:")
            
            for result in results:
                status_symbol = "[OK]" if result.status == TestStatus.PASS else "[FAIL]" if result.status == TestStatus.FAIL else "[WARN]"
                print(f"  {status_symbol} {result.test_type}: {result.message}")
                
                # Show key details
                if result.details:
                    if result.test_type == "Packages" and "total_count" in result.details:
                        print(f"    Packages: {result.details['total_count']}")
                    elif result.test_type == "Services" and "enabled_services" in result.details:
                        print(f"    Services: {len(result.details['enabled_services'])}")
                    elif result.test_type == "Configuration" and "present" in result.details:
                        print(f"    Config files: {len(result.details['present'])}")
        
        # Overall status
        failed_tests = [r for r in self.results if r.status == TestStatus.FAIL]
        warning_tests = [r for r in self.results if r.status == TestStatus.WARN]
        
        print(f"\nOVERALL STATUS:")
        print(f"  Total tests: {len(self.results)}")
        print(f"  Failed: {len(failed_tests)}")
        print(f"  Warnings: {len(warning_tests)}")
        print(f"  Passed: {len(self.results) - len(failed_tests) - len(warning_tests)}")
        
        if failed_tests:
            print(f"\nFAILED TESTS:")
            for test in failed_tests:
                print(f"  - {test.wm_name} {test.test_type}: {test.message}")
        
        if warning_tests:
            print(f"\nWARNINGS:")
            for test in warning_tests[:5]:  # Show first 5 warnings
                print(f"  - {test.wm_name} {test.test_type}: {test.message}")
        
        # Exit with appropriate code
        if failed_tests:
            sys.exit(1)
        elif warning_tests:
            sys.exit(0)
        else:
            sys.exit(0)

def main():
    """Main entry point"""
    config_path = sys.argv[1] if len(sys.argv) > 1 else "."
    
    suite = WindowManagerTestSuite(config_path)
    suite.run_all_tests()

if __name__ == "__main__":
    main()
