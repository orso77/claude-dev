/*
    WheelsNet.dbo.SpNtsArticoUpsertSpares
    -------------------------------------
    Upsert di UN ricambio / ruotino in srvsql.dbtopruote.dbo.artico
    (ditta TOPRUOTE), a partire da dbo.Spares.Id.

    Pattern: UPDATE ... FROM + INSERT ... WHERE NOT EXISTS, come la gia'
    collaudata dbo.SpNtsBrandsUpsert. Niente MERGE e niente transazione
    esplicita: artico ha 4 trigger attivi e una transazione distribuita
    richiederebbe MSDTC.

    Se @id non esiste in dbo.Spares: nessuna riga toccata, nessun errore.
    ar_codalt e ar_hhean si aggiornano solo se la sorgente ha un valore reale.

    TEST (sola lettura, non scrive nulla):
        EXEC dbo.SpNtsArticoUpsertSpares 'RUNUVKRL0001A', @debug = 1;

    USO:
        EXEC dbo.SpNtsArticoUpsertSpares 'RUNUVKRL0001A';
*/
CREATE OR ALTER PROCEDURE dbo.SpNtsArticoUpsertSpares
     @id    VARCHAR(50)
    ,@debug BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @now  DATETIME = GETDATE();
    DECLARE @hhmm INT      = DATEPART(HOUR, @now) * 100 + DATEPART(MINUTE, @now);

    -- ar_datini / ar_datfin vanno passati ESPLICITI. I default constraint di
    -- artico sono letterali varchar ('1900/1/1', '2099/12/31') e la sessione
    -- del linked server gira con @@LANGUAGE = Italiano (dateformat dmy):
    -- '2099/12/31' viene letto come mese 31 e produce l'errore 242.
    DECLARE @datIni DATETIME = '19000101';
    DECLARE @datFin DATETIME = '20991231';

    ----------------------------------------------------------------------
    -- @debug = 1: confronto affiancato, nessuna scrittura
    ----------------------------------------------------------------------
    IF (@debug = 1)
    BEGIN
        SELECT
             src = 'WheelsNet'
            ,ar_codart, ar_descr, ar_desint, ar_codalt, ar_hhean
            ,ar_gruppo, ar_sotgru, ar_famprod, ar_codnomc, ar_accsotgrup
            ,ar_pesonet, ar_pesolor
            ,ar_cermis, ar_cerdiam, ar_cerfor, ar_cerinter1, ar_pndiam
        FROM dbo.ViewNtsSyncSpares
        WHERE ar_codart = @id

        UNION ALL

        SELECT
             src = 'DBTOPRUOTE'
            ,ar_codart, ar_descr, ar_desint, ar_codalt, ar_hhean
            ,ar_gruppo, ar_sotgru, ar_famprod, ar_codnomc, ar_accsotgrup
            ,ar_pesonet, ar_pesolor
            ,ar_cermis, ar_cerdiam, ar_cerfor, ar_cerinter1, ar_pndiam
        FROM srvsql.dbtopruote.dbo.artico
        WHERE codditt = 'TOPRUOTE'
          AND ar_codart = @id;

        RETURN;
    END

    ----------------------------------------------------------------------
    -- UPDATE: solo i campi governati da WheelsNet
    ----------------------------------------------------------------------
    UPDATE a
        SET
             a.ar_descr      = s.ar_descr
            ,a.ar_desint     = s.ar_desint
            ,a.ar_codalt     = COALESCE(s.ar_codalt, a.ar_codalt)
            ,a.ar_hhean      = COALESCE(s.ar_hhean,  a.ar_hhean)
            ,a.ar_gruppo     = s.ar_gruppo
            ,a.ar_sotgru     = s.ar_sotgru
            ,a.ar_claprov    = s.ar_claprov
            ,a.ar_famprod    = s.ar_famprod
            ,a.ar_codnomc    = s.ar_codnomc
            ,a.ar_accsotgrup = s.ar_accsotgrup
            ,a.ar_pesonet    = s.ar_pesonet
            ,a.ar_pesolor    = s.ar_pesolor
            ,a.ar_cermis     = s.ar_cermis
            ,a.ar_cerdiam    = s.ar_cerdiam
            ,a.ar_cerfor     = s.ar_cerfor
            ,a.ar_cerinter1  = s.ar_cerinter1
            ,a.ar_pndiam     = s.ar_pndiam
            ,a.ar_ultagg     = @now
            ,a.ar_oragg      = @hhmm
    FROM srvsql.dbtopruote.dbo.artico a
    INNER JOIN dbo.ViewNtsSyncSpares s
        ON s.ar_codart = a.ar_codart
    WHERE a.codditt   = 'TOPRUOTE'
      AND a.ar_codart = @id
      AND s.ar_codart = @id;

    ----------------------------------------------------------------------
    -- INSERT: solo se l'articolo non esiste
    ----------------------------------------------------------------------
    INSERT INTO srvsql.dbtopruote.dbo.artico
    (
         codditt
        ,ar_codart
        ,ar_descr
        ,ar_desint
        ,ar_codalt
        ,ar_hhean
        ,ar_gruppo
        ,ar_sotgru
        ,ar_claprov
        ,ar_controp
        ,ar_controa
        ,ar_contros
        ,ar_famprod
        ,ar_codnomc
        ,ar_accsotgrup
        ,ar_unmis
        ,ar_conver
        ,ar_qtacon2
        ,ar_codiva
        ,ar_prorig
        ,ar_paeorig
        ,ar_paeorigv
        ,ar_umintra2
        ,ar_pesonet
        ,ar_pesolor
        ,ar_cermis
        ,ar_cerdiam
        ,ar_cerfor
        ,ar_cerinter1
        ,ar_pndiam
        ,ar_datins
        ,ar_orins
        ,ar_ultagg
        ,ar_oragg
        ,ar_datini
        ,ar_datfin
    )
    SELECT
         codditt       = s.codditt
        ,ar_codart     = s.ar_codart
        ,ar_descr      = s.ar_descr
        ,ar_desint     = s.ar_desint
        ,ar_codalt     = s.ar_codalt
        ,ar_hhean      = s.ar_hhean
        ,ar_gruppo     = s.ar_gruppo
        ,ar_sotgru     = s.ar_sotgru
        ,ar_claprov    = s.ar_claprov
        ,ar_controp    = s.ar_controp
        ,ar_controa    = s.ar_controa
        ,ar_contros    = s.ar_contros
        ,ar_famprod    = s.ar_famprod
        ,ar_codnomc    = s.ar_codnomc
        ,ar_accsotgrup = s.ar_accsotgrup
        ,ar_unmis      = s.ar_unmis
        ,ar_conver     = s.ar_conver
        ,ar_qtacon2    = s.ar_qtacon2
        ,ar_codiva     = s.ar_codiva
        ,ar_prorig     = s.ar_prorig
        ,ar_paeorig    = s.ar_paeorig
        ,ar_paeorigv   = s.ar_paeorigv
        ,ar_umintra2   = s.ar_umintra2
        ,ar_pesonet    = s.ar_pesonet
        ,ar_pesolor    = s.ar_pesolor
        ,ar_cermis     = s.ar_cermis
        ,ar_cerdiam    = s.ar_cerdiam
        ,ar_cerfor     = s.ar_cerfor
        ,ar_cerinter1  = s.ar_cerinter1
        ,ar_pndiam     = s.ar_pndiam
        ,ar_datins     = CAST(CAST(@now AS DATE) AS DATETIME)
        ,ar_orins      = @hhmm
        ,ar_ultagg     = @now
        ,ar_oragg      = @hhmm
        ,ar_datini     = @datIni
        ,ar_datfin     = @datFin
    FROM dbo.ViewNtsSyncSpares s
    WHERE s.ar_codart = @id
      AND NOT EXISTS (
            SELECT 1
            FROM srvsql.dbtopruote.dbo.artico a
            WHERE a.codditt   = 'TOPRUOTE'
              AND a.ar_codart = s.ar_codart
        );
END
