@echo off
netsh http add urlacl https://servicename.local:12345/ sddl=D:(A;;GX;;;WD)
