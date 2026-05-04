#!/usr/bin/env python3
"""
Basic NixOS Configuration Test Suite
Tests the basic structure and syntax of the NixOS configuration
"""

import os
import sys
import subprocess
from pathlib import Path
from typing import Dict, List, Tuple, Any
from dataclasses import dataclass
from enum import Enum

class TestStatus(Enum):
    PASS = "PASS"
    FAIL = "FAIL"
    WARN = "WARN"

@dataclass
class TestResult:
    name: str
    status: TestStatus
    message: str
    details: Dict[str, Any] = None

class BasicTestSuite:
    def __init__(self, config_path: str = "."):
        self.config_path = Path(config_path)
        self.results: List[TestResult] = []
    
    def run_test(self, test_name: str, test_func, *args, **kwargs) -> TestResult:
        """Run a single test"""
        try:
            result = test_func(*args, **kwargs)
            if isinstance(result, tuple):
                status, message, details = result
                return TestResult(test_name, status, message, details)
            else:
                status, message = result
                return TestResult(test_name, status, message)
        except Exception as e:
            return TestResult(test_name, TestStatus.FAIL, str(e))
    
    def test_file_exists(self, file_path: str) -> Tuple[TestStatus, str, Dict]:
        """Test if a file exists"""
        full_path = self.config_path / file_path
        
        if full_path.exists():
            return TestStatus.PASS, f"File OK: {file_path}", {"size": full_path.stat().st_size}
        else:
            return TestStatus.FAIL, f"File missing: {file_path}", {}
    
    def test_directory_exists(self, dir_path: str) -> Tuple[TestStatus, str, Dict]:
        """Test if a directory exists"""
        full_path = self.config_path / dir_path
        
        if full_path.exists() and full_path.is_dir():
            return TestStatus.PASS, f"Directory OK: {dir_path}", {"items": len(list(full_path.iterdir()))}
        else:
            return TestStatus.FAIL, f"Directory missing: {dir_path}", {}
    
    def test_nix_syntax(self, file_path: str) -> Tuple[TestStatus, str, Dict]:
        """Test Nix file syntax"""
        full_path = self.config_path / file_path
        
        if not full_path.exists():
            return TestStatus.FAIL, f"File not found: {file_path}", {}
        
        try:
            # Try to parse the Nix file
            result = subprocess.run(
                ["nix-instantiate", "--eval", "--parse", str(full_path)],
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode == 0:
                return TestStatus.PASS, f"Syntax OK: {file_path}", {"lines": len(full_path.read_text().splitlines())}
            else:
                return TestStatus.FAIL, f"Syntax error in {file_path}: {result.stderr.strip()}", {}
                
        except subprocess.TimeoutExpired:
            return TestStatus.FAIL, f"Timeout parsing {file_path}", {}
        except FileNotFoundError:
            # nix-institute not available, do basic check
            try:
                content = full_path.read_text()
                # Basic syntax checks
                if content.count('{') != content.count('}'):
                    return TestStatus.WARN, f"Syntax warning in {file_path}: Unmatched braces", {}
                return TestStatus.PASS, f"Basic syntax OK: {file_path}", {"lines": len(content.splitlines())}
            except Exception as e:
                return TestStatus.FAIL, f"Error reading {file_path}: {e}", {}
    
    def run_basic_tests(self):
        """Run basic structure tests"""
        print("Basic NixOS Configuration Test Suite")
        print("=" * 50)
        
        # Core files
        core_files = [
            "flake.nix",
            "nixos/modules/default.nix",
            "home/default.nix",
            "hosts/registry.nix",
            "lib/build-hosts.nix"
        ]
        
        print("\n[1] Core Structure Tests")
        for file_path in core_files:
            result = self.run_test(f"File: {file_path}", self.test_file_exists, file_path)
            self.results.append(result)
            print(f"  {result.status.value}: {result.message}")
        
        # Core directories
        core_dirs = [
            "nixos/modules",
            "home/programs",
            "hosts",
            "lib",
            "docs"
        ]
        
        print("\n[2] Directory Structure Tests")
        for dir_path in core_dirs:
            result = self.run_test(f"Directory: {dir_path}", self.test_directory_exists, dir_path)
            self.results.append(result)
            print(f"  {result.status.value}: {result.message}")
        
        # Nix syntax tests
        nix_files = [
            "flake.nix",
            "nixos/modules/default.nix",
            "home/default.nix",
            "hosts/athena/default.nix",
            "hosts/nixos-vm/default.nix"
        ]
        
        print("\n[3] Syntax Tests")
        for file_path in nix_files:
            result = self.run_test(f"Syntax: {file_path}", self.test_nix_syntax, file_path)
            self.results.append(result)
            print(f"  {result.status.value}: {result.message}")
        
        # Generate report
        self.generate_report()
    
    def generate_report(self):
        """Generate test report"""
        print("\n" + "=" * 50)
        print("TEST REPORT")
        print("=" * 50)
        
        # Count results by status
        status_counts = {}
        for result in self.results:
            status_counts[result.status] = status_counts.get(result.status, 0) + 1
        
        print(f"Total Tests: {len(self.results)}")
        print("Results by Status:")
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
        
        # Overall status
        if failed_tests:
            print(f"\nOVERALL STATUS: FAIL ({len(failed_tests)} failures)")
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
    
    suite = BasicTestSuite(config_path)
    suite.run_basic_tests()

if __name__ == "__main__":
    main()
