expdp parfile=01.ADM_APPLIED_CHARGES.ctl
gzip *dmp
expdp parfile=02.ADM_PROMOTIONS_HIST.ctl
gzip *dmp
expdp parfile=03.ADM_REPORT_RECURRING_RECHARGE.ctl
gzip *dmp
expdp parfile=04.ADM_REQUESTS.ctl
gzip *dmp
expdp parfile=05.MTH_AA_NOTIF.ctl
gzip *dmp
expdp parfile=06.MTH_APPLIED_RECHARGE.ctl
gzip *dmp
expdp parfile=07.MTH_INTERNATIONAL_RECHARGES.ctl
gzip *dmp