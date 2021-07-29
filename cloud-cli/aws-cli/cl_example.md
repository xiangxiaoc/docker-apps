Example  6:  To  describe  instances with a specific tag and filter the
results to specific fields

The following describe-instances  example  displays  the  instance  ID,
Availability  Zone,  and  the  value of the Name tag for instances that
have a tag with the name tag-key.

```shell script
aws ec2 describe-instances \
    --filter Name=tag-key,Values=Name \
    --query 'Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Name:Tags[?Key==`Name`]|[0].Value}' \
    --output table
```
```powershell
aws ec2 describe-instances ^
    --filter Name=tag-key,Values=Name ^
    --query "Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Name:Tags[?Key=='Name']|[0].Value}" ^
    --output table
```