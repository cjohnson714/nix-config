#!/usr/bin/env python3
"""
Advanced NixOS Configuration Test Suite
Comprehensive testing for enterprise-grade NixOS configuration v3
"""

import os
import sys
import json
import time
import hashlib
from pathlib import Path
from typing import Dict, List, Tuple, Any
from dataclasses import dataclass
from enum import Enum

class TestStatus(Enum):
    PASS = "PASS"
    FAIL = "FAIL"
    WARN = "WARN"
    SKIP = "SKIP"

@dataclass
class TestResult:
    name: str
    status: TestStatus
    message: str
    duration: float
    details: Dict[str, Any] = None

class AdvancedTestSuite:
    def __init__(self, config_path: str = "."):
        self.config_path = Path(config_path)
        self.results: List[TestResult] = []
        self.start_time = time.time()
        
    def run_test(self, test_name: str, test_func, *args, **kwargs) -> TestResult:
        """Run a single test and return result"""
        start = time.time()
        try:
            result = test_func(*args, **kwargs)
            duration = time.time() - start
            if isinstance(result, tuple):
                status, message, details = result
                return TestResult(test_name, status, message, duration, details)
            else:
                status, message = result
                return TestResult(test_name, status, message, duration)
        except Exception as e:
            duration = time.time() - start
            return TestResult(test_name, TestStatus.FAIL, str(e), duration)
    
    def check_file_advanced(self, path: str, description: str) -> Tuple[TestStatus, str, Dict]:
        """Advanced file checking with metadata"""
        full_path = self.config_path / path
        
        if not full_path.exists():
            return TestStatus.FAIL, f"File missing: {path}", {"size": 0, "hash": None}
        
        try:
            stat = full_path.stat()
            size = stat.st_size
            mtime = stat.st_mtime
            
            # Calculate hash for integrity
            with open(full_path, 'rb') as f:
                content = f.read()
                file_hash = hashlib.md5(content).hexdigest()
            
            details = {
                "size": size,
                "hash": file_hash,
                "mtime": mtime,
                "readable": os.access(full_path, os.R_OK)
            }
            
            return TestStatus.PASS, f"File OK: {path}", details
            
        except Exception as e:
            return TestStatus.FAIL, f"Error checking {path}: {e}", {"size": 0, "hash": None}
    
    def check_nix_syntax_advanced(self, path: str) -> Tuple[TestStatus, str, Dict]:
        """Advanced Nix syntax checking"""
        full_path = self.config_path / path
        
        if not full_path.exists():
            return TestStatus.FAIL, f"File missing: {path}", {"lines": 0, "errors": []}
        
        try:
            with open(full_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            lines = content.split('\n')
            line_count = len(lines)
            
            # Advanced syntax checks
            errors = []
            warnings = []
            
            # Check for balanced braces
            open_braces = content.count('{')
            close_braces = content.count('}')
            if open_braces != close_braces:
                errors.append(f"Unbalanced braces: {open_braces} open, {close_braces} close")
            
            # Check for common issues
            if 'import' in content and not content.strip().startswith('{'):
                warnings.append("File contains imports but doesn't start with '{'")
            
            # Check for trailing whitespace
            for i, line in enumerate(lines, 1):
                if line.endswith(' ') or line.endswith('\t'):
                    warnings.append(f"Trailing whitespace on line {i}")
            
            # Check for long lines
            for i, line in enumerate(lines, 1):
                if len(line) > 100:
                    warnings.append(f"Long line ({len(line)} chars) on line {i}")
            
            details = {
                "lines": line_count,
                "errors": errors,
                "warnings": warnings,
                "size": len(content)
            }
            
            if errors:
                return TestStatus.FAIL, f"Syntax errors in {path}", details
            elif warnings:
                return TestStatus.WARN, f"Syntax OK with warnings in {path}", details
            else:
                return TestStatus.PASS, f"Syntax OK: {path}", details
                
        except Exception as e:
            return TestStatus.FAIL, f"Error parsing {path}: {e}", {"lines": 0, "errors": [str(e)]}
    
    def analyze_dependencies(self, path: str) -> Tuple[TestStatus, str, Dict]:
        """Analyze configuration dependencies"""
        full_path = self.config_path / path
        
        if not full_path.exists():
            return TestStatus.FAIL, f"File missing: {path}", {"imports": [], "depth": 0}
        
        try:
            with open(full_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Extract imports
            imports = []
            for line in content.split('\n'):
                if 'import' in line and '=' in line:
                    # Extract import paths
                    if './' in line:
                        import_path = line.split('./')[1].split('"')[0].split("'")[0]
                        imports.append(import_path)
            
            # Calculate dependency depth
            max_depth = 0
            for imp in imports:
                depth = imp.count('/')
                max_depth = max(max_depth, depth)
            
            # Check for circular dependencies (basic check)
            circular_risk = any('..' in imp for imp in imports)
            
            details = {
                "imports": imports,
                "import_count": len(imports),
                "max_depth": max_depth,
                "circular_risk": circular_risk
            }
            
            if circular_risk:
                return TestStatus.WARN, f"Potential circular dependencies in {path}", details
            else:
                return TestStatus.PASS, f"Dependencies OK: {path}", details
                
        except Exception as e:
            return TestStatus.FAIL, f"Error analyzing {path}: {e}", {"imports": [], "depth": 0}
    
    def check_window_manager_structure(self, wm_name: str) -> Tuple[TestStatus, str, Dict]:
        """Check window manager structure completeness"""
        wm_path = self.config_path / f"nixos/modules/desktop/window-managers/{wm_name}"
        
        required_dirs = ["core", "packages", "config"]
        required_files = ["default.nix"]
        
        missing_dirs = []
        missing_files = []
        
        for dir_name in required_dirs:
            if not (wm_path / dir_name).exists():
                missing_dirs.append(dir_name)
        
        for file_name in required_files:
            if not (wm_path / file_name).exists():
                missing_files.append(file_name)
        
        # Check for WM-specific files
        wm_files = []
        if wm_path.exists():
            wm_files = [f.name for f in wm_path.rglob("*.nix") if f.is_file()]
        
        details = {
            "missing_dirs": missing_dirs,
            "missing_files": missing_files,
            "total_files": len(wm_files),
            "file_list": wm_files[:10]  # First 10 files
        }
        
        if missing_dirs or missing_files:
            return TestStatus.FAIL, f"Incomplete {wm_name} structure", details
        else:
            return TestStatus.PASS, f"Complete {wm_name} structure", details
    
    def performance_benchmark(self) -> Tuple[TestStatus, str, Dict]:
        """Benchmark configuration performance"""
        start = time.time()
        
        # Count files and calculate complexity
        nix_files = list(self.config_path.rglob("*.nix"))
        total_lines = 0
        total_size = 0
        
        for file_path in nix_files:
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    total_lines += len(content.split('\n'))
                    total_size += len(content)
            except:
                pass
        
        scan_time = time.time() - start
        
        # Calculate complexity metrics
        file_count = len(nix_files)
        avg_lines_per_file = total_lines / file_count if file_count > 0 else 0
        complexity_score = file_count + (total_lines / 1000) + (total_size / 1000000)
        
        details = {
            "file_count": file_count,
            "total_lines": total_lines,
            "total_size": total_size,
            "avg_lines_per_file": avg_lines_per_file,
            "complexity_score": complexity_score,
            "scan_time": scan_time
        }
        
        # Performance classification
        if complexity_score < 50:
            return TestStatus.PASS, "Low complexity configuration", details
        elif complexity_score < 100:
            return TestStatus.PASS, "Medium complexity configuration", details
        else:
            return TestStatus.WARN, "High complexity configuration", details
    
    def security_validation(self) -> Tuple[TestStatus, str, Dict]:
        """Basic security validation"""
        issues = []
        
        # Check for potential security issues
        for file_path in self.config_path.rglob("*.nix"):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read().lower()
                
                # Check for hardcoded passwords
                if 'password' in content and '=' in content:
                    issues.append(f"Potential password in {file_path.relative_to(self.config_path)}")
                
                # Check for SSH keys
                if 'ssh-rsa' in content or 'ssh-dss' in content:
                    issues.append(f"SSH key in {file_path.relative_to(self.config_path)}")
                
            except:
                pass
        
        details = {
            "issues": issues,
            "issue_count": len(issues),
            "files_scanned": len(list(self.config_path.rglob("*.nix")))
        }
        
        if issues:
            return TestStatus.WARN, f"Security issues found: {len(issues)}", details
        else:
            return TestStatus.PASS, "No obvious security issues", details
    
    def run_comprehensive_tests(self):
        """Run the complete test suite"""
        print("Advanced NixOS Configuration Test Suite v3")
        print("=" * 60)
        
        # Core structure tests
        print("\n[1] Core Structure Tests")
        core_files = [
            ("flake.nix", "Flake configuration"),
            ("nixos/modules/default.nix", "NixOS modules entry"),
            ("home/default.nix", "Home Manager entry"),
            ("hosts/registry.nix", "Host registry"),
            ("lib/build-hosts.nix", "Build hosts utility"),
        ]
        
        for file_path, description in core_files:
            result = self.run_test(f"Core: {description}", self.check_file_advanced, file_path, description)
            self.results.append(result)
            print(f"  {result.status.value}: {result.message}")
        
        # Advanced syntax tests
        print("\n[2] Advanced Syntax Tests")
        syntax_files = [
            "flake.nix",
            "nixos/modules/default.nix",
            "home/default.nix",
            "hosts/athena/default.nix",
            "hosts/nixos-vm/default.nix"
        ]
        
        for file_path in syntax_files:
            result = self.run_test(f"Syntax: {file_path}", self.check_nix_syntax_advanced, file_path)
            self.results.append(result)
            print(f"  {result.status.value}: {result.message}")
            if result.details and result.details.get('warnings'):
                for warning in result.details['warnings'][:2]:  # Show first 2 warnings
                    print(f"    Warning: {warning}")
        
        # Window manager structure tests
        print("\n[3] Window Manager Structure Tests")
        for wm in ["bspwm", "niri", "xfce"]:
            result = self.run_test(f"WM Structure: {wm}", self.check_window_manager_structure, wm)
            self.results.append(result)
            print(f"  {result.status.value}: {result.message}")
        
        # Dependency analysis
        print("\n[4] Dependency Analysis")
        dep_files = [
            "nixos/modules/default.nix",
            "hosts/athena/default.nix",
            "hosts/nixos-vm/default.nix"
        ]
        
        for file_path in dep_files:
            result = self.run_test(f"Deps: {file_path}", self.analyze_dependencies, file_path)
            self.results.append(result)
            print(f"  {result.status.value}: {result.message}")
            if result.details:
                deps = result.details.get('imports', [])
                print(f"    Imports: {len(deps)} files, max depth: {result.details.get('max_depth', 0)}")
        
        # Performance benchmark
        print("\n[5] Performance Benchmark")
        result = self.run_test("Performance Benchmark", self.performance_benchmark)
        self.results.append(result)
        print(f"  {result.status.value}: {result.message}")
        if result.details:
            print(f"    Files: {result.details['file_count']}, Lines: {result.details['total_lines']}")
            print(f"    Complexity score: {result.details['complexity_score']:.2f}")
        
        # Security validation
        print("\n[6] Security Validation")
        result = self.run_test("Security Check", self.security_validation)
        self.results.append(result)
        print(f"  {result.status.value}: {result.message}")
        if result.details and result.details.get('issues'):
            for issue in result.details['issues'][:3]:  # Show first 3 issues
                print(f"    Issue: {issue}")
        
        # Generate report
        self.generate_report()
    
    def generate_report(self):
        """Generate comprehensive test report"""
        total_time = time.time() - self.start_time
        
        # Count results by status
        status_counts = {}
        for result in self.results:
            status_counts[result.status] = status_counts.get(result.status, 0) + 1
        
        print("\n" + "=" * 60)
        print("TEST REPORT")
        print("=" * 60)
        
        print(f"Total Tests: {len(self.results)}")
        print(f"Total Time: {total_time:.2f}s")
        print(f"Average Test Time: {total_time/len(self.results):.3f}s")
        
        print("\nResults by Status:")
        for status, count in status_counts.items():
            print(f"  {status.value}: {count}")
        
        # Failed tests
        failed_tests = [r for r in self.results if r.status == TestStatus.FAIL]
        if failed_tests:
            print(f"\nFAILED TESTS ({len(failed_tests)}):")
            for test in failed_tests:
                print(f"  - {test.name}: {test.message}")
        
        # Warnings
        warning_tests = [r for r in self.results if r.status == TestStatus.WARN]
        if warning_tests:
            print(f"\nWARNINGS ({len(warning_tests)}):")
            for test in warning_tests:
                print(f"  - {test.name}: {test.message}")
        
        # Performance summary
        perf_result = next((r for r in self.results if "Performance" in r.name), None)
        if perf_result and perf_result.details:
            print(f"\nPERFORMANCE SUMMARY:")
            details = perf_result.details
            print(f"  Configuration files: {details['file_count']}")
            print(f"  Total lines: {details['total_lines']}")
            print(f"  Complexity score: {details['complexity_score']:.2f}")
        
        # Overall status
        if failed_tests:
            print(f"\nOVERALL STATUS: FAIL ({len(failed_tests)} failed)")
            sys.exit(1)
        elif warning_tests:
            print(f"\nOVERALL STATUS: PASS with warnings ({len(warning_tests)} warnings)")
            sys.exit(0)
        else:
            print(f"\nOVERALL STATUS: PASS (All tests passed)")
            sys.exit(0)

def main():
    """Main entry point"""
    config_path = sys.argv[1] if len(sys.argv) > 1 else "."
    
    suite = AdvancedTestSuite(config_path)
    suite.run_comprehensive_tests()

if __name__ == "__main__":
    main()
