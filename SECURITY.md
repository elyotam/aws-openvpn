# Security policy

Do not open a public issue containing credentials, activation keys, VPN profiles, private keys, Terraform state, customer IP ranges, AWS account IDs, or other customer information.

Before every deployment:

1. Review the Terraform plan.
2. Confirm that the AWS account and Region are correct.
3. Restrict administrator CIDRs.
4. Keep SSH disabled unless it is explicitly required.
5. Use a separate remote state for each customer and environment.
6. Never store passwords or an OpenVPN activation key in `user_data`, `terraform.tfvars`, Git, or Terraform state.
7. Replace the self-signed web certificate with a trusted certificate before production use.

Report security problems privately to the repository owner.
