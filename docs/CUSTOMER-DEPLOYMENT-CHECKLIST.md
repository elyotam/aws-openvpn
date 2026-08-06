# Customer deployment checklist

## Before writing code

- Obtain written authorization to work in the customer AWS account.
- Confirm the AWS account ID and Region.
- Confirm the VPC ID and public subnet ID.
- Confirm the private networks users must reach through the VPN.
- Decide whether the customer owns a DNS name such as `vpn.example.com`.
- Collect trusted administrator public CIDRs.
- Decide how many simultaneous VPN connections are needed.
- Agree on backup, monitoring, patching, and support ownership.

## Before `terraform plan`

- Create a separate state bucket or separate state key for this customer.
- Confirm that no customer secrets are stored in Git.
- Confirm that no values from another customer remain in `terraform.tfvars`.
- Run `aws sts get-caller-identity` and verify the account ID.
- Run `terraform fmt -check -recursive`.
- Run `terraform validate`.

## Before `terraform apply`

- Save and review the plan.
- Confirm that the plan does not modify unrelated resources.
- Confirm that the Elastic IP and instance are created in the intended Region.
- Obtain customer approval for the expected AWS and OpenVPN licensing costs.
- Obtain explicit approval to apply.

## After deployment

- Connect through SSM Session Manager.
- Review `/var/log/openvpn-access-server-bootstrap.log`.
- Review `/usr/local/openvpn_as/init.log` for initial Access Server details.
- Sign in to the Admin UI and immediately change the administrator password.
- Accept the EULA and activate the customer-owned license.
- Configure private networks, DNS, authentication, MFA, and user permissions.
- Replace the self-signed web certificate.
- Test access from a VPN client to each approved private network.
- Configure backups, monitoring, patching, and alerting.
- Record the owner, recovery procedure, and renewal date.
