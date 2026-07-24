rem ============================================================================
rem  356automotive - export STOCK per cliente (modalita' revorim / SqlToFile)
rem  Rimpiazza il vecchio 356sparewheels-stock-customer.bat (View356Stock + app).
rem  Stored: WheelSystemsExport.dbo.SpStock_356V001         (standard, 17 col)
rem          WheelSystemsExport.dbo.SpStock_356NuvolariV001 (13 col, tagliabue)
rem  I file fitment (FitmentSpares_356V00x.csv) sono prodotti a parte e attesi
rem  in C:\App\SqlToCsv\output\356automotive\ (come nel vecchio flusso).
rem  NB: confermare la base FTP di destinazione: \\192.168.100.100\ftp\356automotive
rem ============================================================================
rem task scheduler utente System - esegui con privilegi piu' elevati

net use \\192.168.100.100 /user:mama\administrator Tact1cal#

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000522" "C:\App\SqlToCsv\output\356automotive\53000522_4s.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000522_4s.csv" "\\192.168.100.100\ftp\356automotive\4s\356-4s-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\4s\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000541" "C:\App\SqlToCsv\output\356automotive\53000541_bracchi.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000541_bracchi.csv" "\\192.168.100.100\ftp\356automotive\bracchi\356-bracchi-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\bracchi\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000046" "C:\App\SqlToCsv\output\356automotive\53000046_campelli.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000046_campelli.csv" "\\192.168.100.100\ftp\356automotive\campelli\356-campelli-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\campelli\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000534" "C:\App\SqlToCsv\output\356automotive\53000534_grassini.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000534_grassini.csv" "\\192.168.100.100\ftp\356automotive\grassini\356-grassini-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\grassini\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000706" "C:\App\SqlToCsv\output\356automotive\53000706_happygomme.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000706_happygomme.csv" "\\192.168.100.100\ftp\356automotive\happygomme\356-happygomme-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\happygomme\sparewheels-fitment-list.csv"

rem questo è il file di md ma viene inviato anche a pneutec 53000431
app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000006" "C:\App\SqlToCsv\output\356automotive\53000006_md.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000006_md.csv" "\\192.168.100.100\ftp\356automotive\md\356-md-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\md\sparewheels-fitment-list.csv"
rem send via ftp
C:\WINDOWS\SYSTEM32\FTP.EXE  -s:D:\app\Export.New\ftp_cred\md.ftp.txt
ftp_cred\winscp.com /ini=nul /script=ftp_cred\pneutec.ftp.txt  -s:ftp_cred\pneutec.ftp.txt
rem questo è il file di md ma viene inviato anche a pneutec 53000431 - fine

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000051" "C:\App\SqlToCsv\output\356automotive\53000051_nizzoli.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000051_nizzoli.csv" "\\192.168.100.100\ftp\356automotive\nizzoli\356-nizzoli-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\nizzoli\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000442" "C:\App\SqlToCsv\output\356automotive\53000442_palmeri.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000442_palmeri.csv" "\\192.168.100.100\ftp\356automotive\palmeri\356-palmeri-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\palmeri\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000366" "C:\App\SqlToCsv\output\356automotive\53000366_picone.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000366_picone.csv" "\\192.168.100.100\ftp\356automotive\picone\356-picone-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\picone\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000711" "C:\App\SqlToCsv\output\356automotive\53000711_scarpinato.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000711_scarpinato.csv" "\\192.168.100.100\ftp\356automotive\scarpinato\356-scarpinato-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\scarpinato\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000008" "C:\App\SqlToCsv\output\356automotive\53000008_vr.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000008_vr.csv" "\\192.168.100.100\ftp\356automotive\vr\356-vr-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\vr\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000557" "C:\App\SqlToCsv\output\356automotive\53000557_gmp.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000557_gmp.csv" "\\192.168.100.100\ftp\356automotive\gmp\356-gmp-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\gmp\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000640" "C:\App\SqlToCsv\output\356automotive\53000640_elite.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000640_elite.csv" "\\192.168.100.100\ftp\356automotive\elite\356-elite-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\elite\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000805" "C:\App\SqlToCsv\output\356automotive\53000805_cora.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000805_cora.csv" "\\192.168.100.100\ftp\356automotive\cora\stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V005_nuvolari.csv" "\\192.168.100.100\ftp\356automotive\cora\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000661" "C:\App\SqlToCsv\output\356automotive\53000661_giotto.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000661_giotto.csv" "\\192.168.100.100\ftp\356automotive\giotto\356-giotto-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\giotto\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000732" "C:\App\SqlToCsv\output\356automotive\53000732_favilli.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000732_favilli.csv" "\\192.168.100.100\ftp\356automotive\favilli\356-favilli-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\favilli\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000539" "C:\App\SqlToCsv\output\356automotive\53000539_tonin.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000539_tonin.csv" "\\192.168.100.100\ftp\356automotive\tonin\356-tonin-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\tonin\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000705" "C:\App\SqlToCsv\output\356automotive\53000705_agcompany.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000705_agcompany.csv" "\\192.168.100.100\ftp\356automotive\agcompany\356-agcompany-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\agcompany\sparewheels-fitment-list.csv"

rem escluso da Marco il 31/01/2025
rem app\Wheels.Win.Exports exportbycustomer WheelExports View356Stock "output\356\53001423_carpart.csv" 53001423 WheelSystems356 
rem copy output\356\53001423_carpart.csv d:\ftp_356\carpart\356-carpart-stock.csv
rem copy output\356\FitmentSpares_356V002_356.csv d:\ftp_356\carpart\sparewheels-fitment-list.csv

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001404" "C:\App\SqlToCsv\output\356automotive\53001404_toptyre.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001404_toptyre.csv" "\\192.168.100.100\ftp\356automotive\toptyre\356-toptyre-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\toptyre\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001408" "C:\App\SqlToCsv\output\356automotive\53001408_futurpol.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001408_futurpol.csv" "\\192.168.100.100\ftp\356automotive\futurpol\stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\futurpol\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001485" "C:\App\SqlToCsv\output\356automotive\53001485_conean.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001485_conean.csv" "\\192.168.100.100\ftp\356automotive\conean\356-conean-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\conean\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001499" "C:\App\SqlToCsv\output\356automotive\53001499_tyroo.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001499_tyroo.csv" "\\192.168.100.100\ftp\356automotive\tyroo\356-tyroo-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\tyroo\sparewheels-fitment-listv01.csv"
rem send via ftp
C:\WINDOWS\SYSTEM32\FTP.EXE  -s:D:\app\Export.New\ftp_cred\tyroo.ftp.txt

rem app\Wheels.Win.Exports exportbycustomer WheelExports View356Stock "output\356\53001502_keskin.csv" 53001502 WheelSystems356 
rem copy output\356\53001502_keskin.csv d:\ftp_356\keskin\356-keskin-stock.csv
rem copy output\356\FitmentSpares_356V002_356ktype.csv d:\ftp_356\keskin\sparewheels-fitment-listv01.csv

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000007" "C:\App\SqlToCsv\output\356automotive\53000007_afruote.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000007_afruote.csv" "\\192.168.100.100\ftp\356automotive\afruote\356-afruote-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\afruote\sparewheels-fitment-list.csv"

rem app\Wheels.Win.Exports exportbycustomer WheelExports View356Stock_356CompDistr "output\356\53000500_mak.csv" 53000500 WheelSystems356 
rem copy output\356\53000500_mak.csv d:\ftp_356\mak\356-mak-stock.csv
rem NO FITMENT FOR MAK

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001465" "C:\App\SqlToCsv\output\356automotive\53001465_dileo.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001465_dileo.csv" "\\192.168.100.100\ftp\356automotive\dileo\356-dileo-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\dileo\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001517" "C:\App\SqlToCsv\output\356automotive\53001517_aliservice.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001517_aliservice.csv" "\\192.168.100.100\ftp\356automotive\aliservice\356-aliservice-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\aliservice\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001521" "C:\App\SqlToCsv\output\356automotive\53001521_mcwheels.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001521_mcwheels.csv" "\\192.168.100.100\ftp\356automotive\mcwheels\356-mcwheels-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\mcwheels\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001524" "C:\App\SqlToCsv\output\356automotive\53001524_picoportal.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001524_picoportal.csv" "\\192.168.100.100\ftp\356automotive\picoportal\356-picoportal-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V007_356_KwPatternCenterBoreLoad.csv" "\\192.168.100.100\ftp\356automotive\picoportal\sparewheels-fitment-list-v02.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000340" "C:\App\SqlToCsv\output\356automotive\53000340_masserut.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000340_masserut.csv" "\\192.168.100.100\ftp\356automotive\masserut\356-masserut-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\masserut\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001449" "C:\App\SqlToCsv\output\356automotive\53001449_wheelsrapid.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001449_wheelsrapid.csv" "\\192.168.100.100\ftp\356automotive\wheelsrapid\356-wheelsrapid-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\wheelsrapid\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001553" "C:\App\SqlToCsv\output\356automotive\53001553_bonansone.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001553_bonansone.csv" "\\192.168.100.100\ftp\356automotive\bonansone\356-bonansone-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\bonansone\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000539" "C:\App\SqlToCsv\output\356automotive\53000539_toningomme.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000539_toningomme.csv" "\\192.168.100.100\ftp\356automotive\toningomme\356-toningomme-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\toningomme\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001756" "C:\App\SqlToCsv\output\356automotive\53001756_wsptrading.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001756_wsptrading.csv" "\\192.168.100.100\ftp\356automotive\wsptrading\356-wsptrading-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\wsptrading\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000736" "C:\App\SqlToCsv\output\356automotive\53000736_pneusin.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000736_pneusin.csv" "\\192.168.100.100\ftp\356automotive\pneusin\356-pneusin-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\pneusin\sparewheels-fitment-list.csv"

rem app\Wheels.Win.Exports exportbycustomer WheelExports View356Stock_356CompDistr "output\356\53001763_extradeon.csv" 53001763 WheelSystems356 
rem copy output\356\53001763_extradeon.csv d:\ftp_356\extradeon\356-extradeon-stock.csv
rem NO FITMENT FOR extradeon

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001764" "C:\App\SqlToCsv\output\356automotive\53001764_eurawheels.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001764_eurawheels.csv" "\\192.168.100.100\ftp\356automotive\eurawheels\356-eurawheels-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\eurawheels\sparewheels-fitment-list.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V006_basic.csv" "\\192.168.100.100\ftp\356automotive\eurawheels\sparewheels-fitment-list-basic.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001719" "C:\App\SqlToCsv\output\356automotive\53001719_cartercash.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001719_cartercash.csv" "\\192.168.100.100\ftp\356automotive\cartercash\356-cartercash-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\cartercash\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001765" "C:\App\SqlToCsv\output\356automotive\53001765_givawheels.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001765_givawheels.csv" "\\192.168.100.100\ftp\356automotive\givawheels\356-givawheels-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\givawheels\sparewheels-fitment-listv01.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001247" "C:\App\SqlToCsv\output\356automotive\53001247_pendin.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001247_pendin.csv" "\\192.168.100.100\ftp\356automotive\pendin\356-pendin-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\pendin\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000216" "C:\App\SqlToCsv\output\356automotive\53000216_guglielmi.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000216_guglielmi.csv" "\\192.168.100.100\ftp\356automotive\guglielmi\356-guglielmi-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\guglielmi\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001857" "C:\App\SqlToCsv\output\356automotive\53001857_hispania.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001857_hispania.csv" "\\192.168.100.100\ftp\356automotive\hispania\356-hispania-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V005_nuvolari.csv" "\\192.168.100.100\ftp\356automotive\hispania\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001860" "C:\App\SqlToCsv\output\356automotive\53001860_projex.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001860_projex.csv" "\\192.168.100.100\ftp\356automotive\projex\356-projex-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V005_nuvolari.csv" "\\192.168.100.100\ftp\356automotive\projex\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000824" "C:\App\SqlToCsv\output\356automotive\53000824_donadello.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000824_donadello.csv" "\\192.168.100.100\ftp\356automotive\donadello\356-donadello-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\donadello\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001856" "C:\App\SqlToCsv\output\356automotive\53001856_pitstop.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001856_pitstop.csv" "\\192.168.100.100\ftp\356automotive\pitstop\356-pitstop-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\pitstop\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000361" "C:\App\SqlToCsv\output\356automotive\53000361_falcopneus.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000361_falcopneus.csv" "\\192.168.100.100\ftp\356automotive\falcopneus\356-falcopneus-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\falcopneus\sparewheels-fitment-list.csv"
rem caricamento ftp su server cliente
call ftp_cred\356.ftp.falcopneus.bat "output\356\53000361_falcopneus.csv" "public/falcopneus-stock.csv" "output\356\FitmentSpares_356V002_356.csv" "public/sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001868" "C:\App\SqlToCsv\output\356automotive\53001868_mgm.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001868_mgm.csv" "\\192.168.100.100\ftp\356automotive\mgm\356-mgm-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\mgm\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53000746" "C:\App\SqlToCsv\output\356automotive\53000746_tyreresort.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000746_tyreresort.csv" "\\192.168.100.100\ftp\356automotive\tyreresort\356-tyreresort-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\tyreresort\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001885" "C:\App\SqlToCsv\output\356automotive\53001885_giongo.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001885_giongo.csv" "\\192.168.100.100\ftp\356automotive\giongo\356-giongo-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\giongo\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001893" "C:\App\SqlToCsv\output\356automotive\53001893_tyrelab.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001893_tyrelab.csv" "\\192.168.100.100\ftp\356automotive\tyrelab\356-tyrelab-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\tyrelab\sparewheels-fitment-list.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001214" "C:\App\SqlToCsv\output\356automotive\53001214_mondo.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001214_mondo.csv" "\\192.168.100.100\ftp\356automotive\mondo\356-mondo-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\mondo\sparewheels-fitment-list.csv"

rem oliosb ha solo fitment 01 con ktype come alcar
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356ktype.csv" "\\192.168.100.100\ftp\356automotive\oliosb\sparewheels-fitment-listv01.csv"
rem dal 03/05/2025 Olio SB ha anche gli stock
app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001913" "C:\App\SqlToCsv\output\356automotive\53001913_oliosb.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001913_oliosb.csv" "\\192.168.100.100\ftp\356automotive\oliosb\356-oliosb-stock.csv"

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001481" "C:\App\SqlToCsv\output\356automotive\53001481_taurus.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001481_taurus.csv" "\\192.168.100.100\ftp\356automotive\taurus\taurus-stock.csv"
copy "C:\App\SqlToCsv\output\356automotive\FitmentSpares_356V002_356.csv" "\\192.168.100.100\ftp\356automotive\taurus\sparewheels-fitment-list.csv"

rem escluso il 03/12/2025
rem eintrodotto il 15/01/2026
app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356NuvolariV001 53000577" "C:\App\SqlToCsv\output\356automotive\53000577_tagliabue.csv"
copy "C:\App\SqlToCsv\output\356automotive\53000577_tagliabue.csv" "\\192.168.100.100\ftp\356automotive\tagliabue\356-tagliabue-stock.csv"
rem no fitment for tagliabue

rem tagliabue negozi
app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001933" "C:\App\SqlToCsv\output\356automotive\53001933_tagliabue-negozi.csv"
copy "C:\App\SqlToCsv\output\356automotive\53001933_tagliabue-negozi.csv" "\\192.168.100.100\ftp\356automotive\tagliabue-negozi\356-tagliabue-negozi-stock.csv"
rem no fitment for tagliabue

app\Utilities.SqlToFile WheelSystemsExport "exec SpStock_356V001 53001940" "C:\App\SqlToCsv\output\356automotive\53001940_ravasi.csv"
rem ************************ VA NELL'FTP REVORIM!!! ************************
copy "C:\App\SqlToCsv\output\356automotive\53001940_ravasi.csv" "\\192.168.100.100\ftp\revorim\ravasi-53000027\stock-356.csv"
rem no fitment - prende la AllFitm_V002 di revorim
rem ************************************************************************
