# Common variables
region      = "eu-west-1"
application = "helloworld"
environment = "dev"

# Module variables
cd_app_name         = "app-cd"
cd_compute_platform = "Server"
dg_service_role     = "arn:aws:iam::365101756910:role/dev-CodeDeloyServiceRole"
dg_asg_name         = ["dev-app-asg"]
dg_lb_tg_name       = "dev-app-lb-tg"
sns_email           = "jmartinez.galvez@gmail.com"
