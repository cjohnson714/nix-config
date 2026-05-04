#!/usr/bin/env python3
"""
Security Compliance and Validation Test Suite
Tests security configurations and compliance frameworks
"""

import os
import sys
import json
import re
from pathlib import Path
from typing import Dict, List, Tuple, Any
from dataclasses import dataclass
from enum import Enum

class SecurityStatus(Enum):
    PASS = "PASS"
    FAIL = "FAIL"
    WARN = "WARN"
    INFO = "INFO"

@dataclass
class SecurityTestResult:
    name: str
    status: SecurityStatus
    message: str
    details: Dict[str, Any] = None

class SecurityTestSuite:
    def __init__(self, config_path: str = "."):
        self.config_path = Path(config_path)
        self.results: List[SecurityTestResult] = []
    
    def run_test(self, test_name: str, test_func, *args, **kwargs) -> SecurityTestResult:
        """Run a single security test"""
        try:
            result = test_func(*args, **kwargs)
            if isinstance(result, tuple):
                status, message, details = result
                return SecurityTestResult(test_name, status, message, details)
            else:
                status, message = result
                return SecurityTestResult(test_name, status, message)
        except Exception as e:
            return SecurityTestResult(test_name, SecurityStatus.FAIL, str(e))
    
    def test_password_security(self, file_path: str) -> Tuple[SecurityStatus, str, Dict]:
        """Test for password-related security issues"""
        full_path = self.config_path / file_path
        
        if not full_path.exists():
            return SecurityStatus.INFO, f"File not found: {file_path}", {}
        
        try:
            with open(full_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            issues = []
            
            # Check for hardcoded passwords
            password_patterns = [
                r'password\s*=\s*["\'][^"\']+["\']',
                r'passwd\s*=\s*["\'][^"\']+["\']',
                r'secret\s*=\s*["\'][^"\']+["\']',
                r'key\s*=\s*["\'][^"\']+["\']',
                r'token\s*=\s*["\'][^"\']+["\']',
            ]
            
            for pattern in password_patterns:
                matches = re.findall(pattern, content, re.IGNORECASE)
                if matches:
                    issues.extend(matches)
            
            # Check for potential password fields
            sensitive_fields = re.findall(r'\b(password|passwd|secret|key|token)\b', content, re.IGNORECASE)
            
            details = {
                "file": file_path,
                "password_matches": issues,
                "sensitive_fields": sensitive_fields,
                "line_count": len(content.split('\n'))
            }
            
            if issues:
                return SecurityStatus.FAIL, f"Found {len(issues)} potential passwords", details
            elif sensitive_fields:
                return SecurityStatus.WARN, f"Found {len(sensitive_fields)} sensitive fields", details
            else:
                return SecurityStatus.PASS, "No password issues found", details
                
        except Exception as e:
            return SecurityStatus.FAIL, f"Error reading {file_path}: {e}", {}
    
    def test_ssh_security(self) -> Tuple[SecurityStatus, str, Dict]:
        """Test SSH security configuration"""
        ssh_config = self.config_path / "nixos/modules/services/ssh.nix"
        
        if not ssh_config.exists():
            return SecurityStatus.INFO, "SSH configuration not found", {}
        
        try:
            with open(ssh_config, 'r', encoding='utf-8') as f:
                content = f.read()
            
            security_settings = {
                "permit_root_login": "PermitRootLogin" in content,
                "password_auth": "PasswordAuthentication" in content,
                "pubkey_auth": "PubkeyAuthentication" in content,
                "port_configured": "Port" in content,
                "max_auth_tries": "MaxAuthTries" in content,
            }
            
            # Check for security best practices
            recommendations = []
            
            if "PermitRootLogin yes" in content:
                recommendations.append("Disable root login")
            
            if "PasswordAuthentication yes" in content:
                recommendations.append("Use key-based authentication only")
            
            if not "PermitRootLogin no" in content:
                recommendations.append("Explicitly disable root login")
            
            if not "PasswordAuthentication no" in content:
                recommendations.append("Explicitly disable password authentication")
            
            details = {
                "security_settings": security_settings,
                "recommendations": recommendations,
                "config_exists": True
            }
            
            if recommendations:
                return SecurityStatus.WARN, f"{len(recommendations)} security recommendations", details
            else:
                return SecurityStatus.PASS, "SSH security is well configured", details
                
        except Exception as e:
            return SecurityStatus.FAIL, f"Error checking SSH config: {e}", {}
    
    def test_firewall_security(self) -> Tuple[SecurityStatus, str, Dict]:
        """Test firewall configuration"""
        firewall_files = [
            "nixos/modules/services/firewall.nix",
            "nixos/modules/networking/firewall.nix"
        ]
        
        firewall_config = None
        for file_path in firewall_files:
            full_path = self.config_path / file_path
            if full_path.exists():
                firewall_config = full_path
                break
        
        if not firewall_config:
            return SecurityStatus.WARN, "No firewall configuration found", {}
        
        try:
            with open(firewall_config, 'r', encoding='utf-8') as f:
                content = f.read()
            
            firewall_settings = {
                "enable_firewall": "enable" in content and "true" in content,
                "default_deny": "defaultPolicy" in content,
                "open_ports": len(re.findall(r'tcpPorts|udpPorts', content)),
                "logging": "logging" in content,
            }
            
            # Check for security best practices
            recommendations = []
            
            if not firewall_settings["enable_firewall"]:
                recommendations.append("Enable firewall")
            
            if firewall_settings["open_ports"] > 10:
                recommendations.append("Review open ports")
            
            if not firewall_settings["logging"]:
                recommendations.append("Enable firewall logging")
            
            details = {
                "firewall_file": str(firewall_config),
                "settings": firewall_settings,
                "recommendations": recommendations
            }
            
            if recommendations:
                return SecurityStatus.WARN, f"{len(recommendations)} firewall recommendations", details
            else:
                return SecurityStatus.PASS, "Firewall is well configured", details
                
        except Exception as e:
            return SecurityStatus.FAIL, f"Error checking firewall config: {e}", {}
    
    def test_user_security(self) -> Tuple[SecurityStatus, str, Dict]:
        """Test user security configuration"""
        user_config = self.config_path / "nixos/modules/core/users.nix"
        
        if not user_config.exists():
            return SecurityStatus.INFO, "User configuration not found", {}
        
        try:
            with open(user_config, 'r', encoding='utf-8') as f:
                content = f.read()
            
            user_settings = {
                "sudo_users": len(re.findall(r'wheel|sudo', content, re.IGNORECASE)),
                "passwordless_sudo": "NOPASSWD" in content,
                "shell_restrictions": "shell" in content,
                "user_groups": len(re.findall(r'extraGroups', content)),
            }
            
            # Check for security best practices
            recommendations = []
            
            if user_settings["passwordless_sudo"]:
                recommendations.append("Review passwordless sudo")
            
            if user_settings["sudo_users"] > 5:
                recommendations.append("Review sudo user count")
            
            details = {
                "user_settings": user_settings,
                "recommendations": recommendations
            }
            
            if recommendations:
                return SecurityStatus.WARN, f"{len(recommendations)} user security recommendations", details
            else:
                return SecurityStatus.PASS, "User security is well configured", details
                
        except Exception as e:
            return SecurityStatus.FAIL, f"Error checking user config: {e}", {}
    
    def test_kernel_security(self) -> Tuple[SecurityStatus, str, Dict]:
        """Test kernel security hardening"""
        kernel_config = self.config_path / "nixos/modules/core/kernel.nix"
        
        if not kernel_config.exists():
            return SecurityStatus.INFO, "Kernel configuration not found", {}
        
        try:
            with open(kernel_config, 'r', encoding='utf-8') as f:
                content = f.read()
            
            security_settings = {
                "sysctl_hardening": len(re.findall(r'sysctl', content)),
                "kernel_modules": len(re.findall(r'kernelModules', content)),
                "security_patches": "security" in content.lower(),
                "aslr": "randomize_va_space" in content,
            }
            
            # Check for security best practices
            recommendations = []
            
            if security_settings["sysctl_hardening"] < 5:
                recommendations.append("Add more sysctl hardening")
            
            if not security_settings["aslr"]:
                recommendations.append("Enable ASLR")
            
            details = {
                "kernel_settings": security_settings,
                "recommendations": recommendations
            }
            
            if recommendations:
                return SecurityStatus.WARN, f"{len(recommendations)} kernel security recommendations", details
            else:
                return SecurityStatus.PASS, "Kernel security is well configured", details
                
        except Exception as e:
            return SecurityStatus.FAIL, f"Error checking kernel config: {e}", {}
    
    def test_service_security(self) -> Tuple[SecurityStatus, str, Dict]:
        """Test service security configuration"""
        service_config = self.config_path / "nixos/modules/services/core.nix"
        
        if not service_config.exists():
            return SecurityStatus.INFO, "Service configuration not found", {}
        
        try:
            with open(service_config, 'r', encoding='utf-8') as f:
                content = f.read()
            
            service_settings = {
                "enabled_services": len(re.findall(r'enable\s*=\s*true', content)),
                "disabled_services": len(re.findall(r'enable\s*=\s*false', content)),
                "user_services": len(re.findall(r'user\.services', content)),
                "systemd_hardening": "systemd" in content.lower(),
            }
            
            # Check for security best practices
            recommendations = []
            
            if service_settings["enabled_services"] > 20:
                recommendations.append("Review enabled services")
            
            if not service_settings["systemd_hardening"]:
                recommendations.append("Consider systemd hardening")
            
            details = {
                "service_settings": service_settings,
                "recommendations": recommendations
            }
            
            if recommendations:
                return SecurityStatus.WARN, f"{len(recommendations)} service security recommendations", details
            else:
                return SecurityStatus.PASS, "Service security is well configured", details
                
        except Exception as e:
            return SecurityStatus.FAIL, f"Error checking service config: {e}", {}
    
    def test_compliance_frameworks(self) -> Tuple[SecurityStatus, str, Dict]:
        """Test compliance framework implementations"""
        security_lib = self.config_path / "lib/security.nix"
        
        if not security_lib.exists():
            return SecurityStatus.INFO, "Security library not found", {}
        
        try:
            with open(security_lib, 'r', encoding='utf-8') as f:
                content = f.read()
            
            compliance_frameworks = {
                "cis_benchmarks": "CIS" in content,
                "pci_dss": "PCI" in content,
                "gdpr": "GDPR" in content,
                "sox": "SOX" in content,
                "hipaa": "HIPAA" in content,
            }
            
            implemented_frameworks = [k for k, v in compliance_frameworks.items() if v]
            
            details = {
                "frameworks": compliance_frameworks,
                "implemented_count": len(implemented_frameworks),
                "implemented_frameworks": implemented_frameworks
            }
            
            if len(implemented_frameworks) >= 3:
                return SecurityStatus.PASS, f"Multiple compliance frameworks implemented", details
            elif len(implemented_frameworks) >= 1:
                return SecurityStatus.WARN, f"Basic compliance implemented", details
            else:
                return SecurityStatus.INFO, "No compliance frameworks found", details
                
        except Exception as e:
            return SecurityStatus.FAIL, f"Error checking compliance frameworks: {e}", {}
    
    def run_security_tests(self):
        """Run all security tests"""
        print("Security Compliance and Validation Test Suite")
        print("=" * 60)
        
        # Password security tests
        print("\n[1] Password Security Tests")
        sensitive_files = [
            "lib/automation.nix",
            "lib/security.nix",
            "templates/quick-start/desktop.nix",
            "templates/quick-start/server.nix"
        ]
        
        for file_path in sensitive_files:
            result = self.run_test(f"Password Security: {file_path}", self.test_password_security, file_path)
            self.results.append(result)
            print(f"  {result.status.value}: {result.message}")
        
        # System security tests
        print("\n[2] System Security Tests")
        system_tests = [
            ("SSH Security", self.test_ssh_security),
            ("Firewall Security", self.test_firewall_security),
            ("User Security", self.test_user_security),
            ("Kernel Security", self.test_kernel_security),
            ("Service Security", self.test_service_security),
            ("Compliance Frameworks", self.test_compliance_frameworks),
        ]
        
        for test_name, test_func in system_tests:
            result = self.run_test(test_name, test_func)
            self.results.append(result)
            print(f"  {result.status.value}: {result.message}")
        
        # Generate report
        self.generate_security_report()
    
    def generate_security_report(self):
        """Generate comprehensive security report"""
        print("\n" + "=" * 60)
        print("SECURITY TEST REPORT")
        print("=" * 60)
        
        # Count results by status
        status_counts = {}
        for result in self.results:
            status_counts[result.status] = status_counts.get(result.status, 0) + 1
        
        print(f"Total Tests: {len(self.results)}")
        print("Results by Status:")
        for status, count in status_counts.items():
            print(f"  {status.value}: {count}")
        
        # Failed tests
        failed_tests = [r for r in self.results if r.status == SecurityStatus.FAIL]
        if failed_tests:
            print(f"\nFAILED TESTS ({len(failed_tests)}):")
            for test in failed_tests:
                print(f"  - {test.name}: {test.message}")
                if test.details and test.details.get('recommendations'):
                    for rec in test.details['recommendations'][:3]:
                        print(f"    Recommendation: {rec}")
        
        # Warnings
        warning_tests = [r for r in self.results if r.status == SecurityStatus.WARN]
        if warning_tests:
            print(f"\nWARNINGS ({len(warning_tests)}):")
            for test in warning_tests:
                print(f"  - {test.name}: {test.message}")
                if test.details and test.details.get('recommendations'):
                    for rec in test.details['recommendations'][:2]:
                        print(f"    Recommendation: {rec}")
        
        # Info tests
        info_tests = [r for r in self.results if r.status == SecurityStatus.INFO]
        if info_tests:
            print(f"\nINFO ({len(info_tests)}):")
            for test in info_tests:
                print(f"  - {test.name}: {test.message}")
        
        # Security score
        total_tests = len(self.results)
        passed_tests = len([r for r in self.results if r.status == SecurityStatus.PASS])
        security_score = (passed_tests / total_tests) * 100 if total_tests > 0 else 0
        
        print(f"\nSECURITY SCORE: {security_score:.1f}%")
        
        # Overall status
        if failed_tests:
            print(f"\nOVERALL STATUS: CRITICAL ({len(failed_tests)} critical issues)")
            sys.exit(2)
        elif warning_tests:
            print(f"\nOVERALL STATUS: WARNING ({len(warning_tests)} warnings)")
            sys.exit(1)
        else:
            print(f"\nOVERALL STATUS: SECURE (All tests passed)")
            sys.exit(0)

def main():
    """Main entry point"""
    config_path = sys.argv[1] if len(sys.argv) > 1 else "."
    
    suite = SecurityTestSuite(config_path)
    suite.run_security_tests()

if __name__ == "__main__":
    main()
