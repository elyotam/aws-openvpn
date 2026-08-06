# מודול Terraform להקמת OpenVPN Access Server ב-AWS

![OpenVPN Access Server על גבי AWS](docs/images/openvpn-access-server-aws.png)

זהו פרויקט Clean Room כללי שמקים שרת OpenVPN Access Server בחשבון AWS של לקוח. הוא אינו כולל קוד, כתובות, State, סודות או פרטים של חברה אחרת.

## מה המודול מקים

- שרת EC2 עם Ubuntu 24.04.
- התקנה אוטומטית של OpenVPN Access Server מהמאגר הרשמי.
- Elastic IP קבוע כמשאב עצמאי.
- חיבור EIP נפרד לשרת.
- Security Group לפורטים TCP 443, UDP 1194 ו-TCP 943 לפי CIDR.
- IAM Role ו-SSM Session Manager לניהול בלי לפתוח SSH.
- דיסק gp3 מוצפן ו-IMDSv2 חובה.
- ביטול Source/Destination Check כדי שהשרת יוכל להעביר תעבורה.
- רשומת Route 53 אופציונלית.
- דוגמאות Terraform ו-Terragrunt.

## הפרדה וקישור בין dev ל-staging

התבנית המוכנה להתאמה נמצאת בתיקייה [`environments/dev-staging`](environments/dev-staging). היא מקימה שרת OpenVPN יחיד בתוך ה־VPC של `dev`, ומחברת את `dev` ל־`staging` באמצעות VPC Peering. לקוחות ה־VPN מקבלים נתיב לשתי סביבות ה־non-production. סביבת `production` מוחרגת בכוונה: אין בתבנית משתני production, תלויות, routes או peering אליה.

```text
לקוח VPN
    |
OpenVPN Access Server (dev VPC)
    |                         \
משאבי dev          VPC peering -> משאבי staging

production: אין חיבור
```

ה־stack יוצר:

- OpenVPN Access Server ב־public subnet של `dev`.
- VPC Peering בין `dev` ל־`staging`, כולל DNS resolution.
- Routes מטבלאות הניתוב שנבחרו ב־`dev` אל ה־CIDR של `staging`.
- Return routes מטבלאות הניתוב שנבחרו ב־`staging` אל ה־CIDR של `dev`.
- OpenVPN private-network route שמפרסם ללקוחות ה־VPN את ה־CIDR של `staging`.
- נתיב Terraform State נפרד עבור קישוריות ה־non-production המשותפת.

### התאמה לחברה חדשה

1. העתק את קובצי הדוגמה:

   ```bash
   cd environments/dev-staging
   cp terraform.tfvars.example terraform.tfvars
   cp backend.tf.example backend.tf
   ```

2. החלף את כל ערכי `REPLACE_*` בתוך `terraform.tfvars` ו־`backend.tf`. יש להזין את מזהי ה־VPC של `dev` ו־`staging`, טווחי CIDR שאינם חופפים, public subnet של `dev`, מזהי route tables, כתובות מנהלים מורשות, state bucket, אזור ותגיות של החברה החדשה.
3. ודא שאף VPC, טבלת ניתוב, CIDR, אזור DNS או הרשאת AWS שסופקו אינם שייכים ל־production.
4. השתמש ב־AWS profile או role ייעודי ל־non-production של החברה החדשה ואמת אותו לפני יצירת plan:

   ```bash
   export AWS_PROFILE=REPLACE_CUSTOMER_NONPROD_PROFILE
   aws sts get-caller-identity
   terraform init
   terraform fmt -check -recursive
   terraform validate
   terraform plan
   ```

5. בדוק את שני כיווני הניתוב ב־plan והפעל רק לאחר אישור:

   ```bash
   terraform apply
   ```

אין לבצע commit ל־`terraform.tfvars`, הרשאות backend, קובצי state, פרופילי VPN, סיסמאות, מפתחות פרטיים, מספרי חשבון או ערכי רשת אמיתיים של לקוחות. ה־`.gitignore` מחריג קבצים רגישים נפוצים, אך עדיין חובה לבדוק את ה־plan ואת ה־diff לפני פרסום.

## דרישות מוקדמות

1. חשבון AWS והרשאות מתאימות.
2. VPC קיים.
3. Public Subnet עם Route ל-Internet Gateway.
4. Terraform 1.9 ומעלה.
5. AWS CLI מחובר לחשבון הנכון.
6. רישיון OpenVPN Access Server בבעלות הלקוח. ללא רישיון ניתן להשתמש בשני חיבורים בו-זמנית בהתאם למדיניות OpenVPN.

## התחלה מהירה עם Terraform

```bash

git clone https://github.com/elyotam/aws-openvpn.git
cd aws-openvpn/examples/terraform

cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
```

החלף את כל ערכי הדוגמה, בעיקר:

```hcl
vpc_id    = "vpc-..."
subnet_id = "subnet-..."
admin_cidrs = ["YOUR.PUBLIC.IP/32"]
```

בדוק קודם את החשבון:

```bash
aws sts get-caller-identity
```

בדיקות קוד בלבד:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

בדיקת תכנית ללא שינוי תשתית:

```bash
terraform init
terraform plan
```

רק לאחר אישור מפורש של הלקוח:

```bash
terraform apply
```

## גישה לשרת בלי SSH

המודול מחבר IAM Role של SSM. לאחר ההקמה:

```bash
aws ssm start-session --target i-REPLACE_ME
```

בתוך השרת:

```bash
sudo systemctl status openvpnas --no-pager
sudo cat /var/log/openvpn-access-server-bootstrap.log
sudo cat /usr/local/openvpn_as/init.log
```

## כתובות הממשק

Terraform מחזיר:

```bash
terraform output admin_url
terraform output client_url
```

מבנה הכתובות:

```text
https://VPN-ADDRESS/admin/
https://VPN-ADDRESS/
```

בפעם הראשונה תופיע אזהרת תעודה מכיוון שהתעודה הראשונית היא Self-Signed. בסביבת Production יש להתקין תעודה תקינה.

## הגדרת משתמשים וגישה לרשת

המודול מתקין את המוצר ומקים את תשתית AWS. את הפעולות הבאות מבצעים דרך Admin UI של הלקוח:

1. שינוי סיסמת מנהל.
2. הפעלת רישיון בבעלות הלקוח.
3. הגדרת Authentication ו-MFA.
4. הגדרת הרשתות הפרטיות שאליהן משתמשי VPN רשאים להגיע.
5. יצירת משתמשים וקבוצות.
6. התקנת תעודת SSL תקינה.
7. בדיקות חיבור והרשאות.

## שימוש אצל כמה לקוחות

אין להשתמש באותו State או באותו קובץ משתנים לכמה לקוחות. לכל לקוח צריך להיות:

- חשבון AWS או Role משלו.
- State נפרד.
- VPC ו-Subnet משלו.
- CIDR והרשאות משלו.
- DNS, רישיון וסודות משלו.
- תיקיית Deployment או Repository פרטי משלו.

מומלץ להשתמש בגרסה מתויגת של המודול:

```hcl
module "openvpn" {
  source = "git::https://github.com/elyotam/aws-openvpn.git?ref=v1.0.0"
}
```

## מה לא שומרים ב-Git או ב-Terraform

- Activation Key.
- סיסמת Admin.
- קובצי OVPN.
- Private Keys.
- AWS Credentials.
- Terraform State.
- כתובות פנימיות רגישות ללא צורך.

## מחיקה

הרצת הפקודה הבאה מוחקת את המשאבים שה-Deployment מנהל ועלולה להשבית את ה-VPN:

```bash
terraform destroy
```

אין להריץ אותה ללא אישור מפורש ותכנית גיבוי.

## הערה חשובה

זהו מודול Single Instance. הוא אינו מספק High Availability, Cluster, גיבוי אוטומטי או Disaster Recovery מלא. יש לתכנן את הרכיבים האלה בנפרד עבור לקוחות שדורשים זמינות גבוהה.
