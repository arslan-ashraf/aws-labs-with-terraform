Network ACL Rules:
	- Stateless: Unlike security groups, allowing traffic on port 80 inbound does not automatically allow it outbound.
	- Ephemeral Port Trap: Forgetting to allow outbound traffic to ports 1024-65535 will cause web servers to successfully receive requests but fail to send responses back to clients.
	- Implicit Deny: Any traffic that does not match defined rules will hit the default rule (Rule *) and be blocked automatically.