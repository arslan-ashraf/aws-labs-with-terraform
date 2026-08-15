In this lab, we test the Network Access Control List (NACL) which is a type of firewall that works at the subnet level compared to security group which works at the ENI level.

Network ACL Rules:

1. Stateless: Unlike security groups, allowing traffic on port 80 inbound does not automatically allow it outbound.

2. Ephemeral Port Trap: Forgetting to allow outbound traffic to ports 1024-65535 will cause web servers to successfully receive requests but fail to send responses back to clients.

3. Implicit Deny: Any traffic that does not match of the defined rules will hit the default rule (Rule \*) and be blocked automatically.

