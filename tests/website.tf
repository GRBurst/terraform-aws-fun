module "website" {
  source = "../"

  stage = "stage"

  website = {
    source_dir = "./"
  }

  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
}
