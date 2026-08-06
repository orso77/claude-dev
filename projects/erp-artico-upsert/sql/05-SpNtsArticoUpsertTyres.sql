/*
    WheelsNet.dbo.SpNtsArticoUpsertTyres
    ------------------------------------
    Upsert di UN pneumatico in srvsql.dbtopruote.dbo.artico (ditta TOPRUOTE),
    a partire da dbo.Tyres.Id.

    Pattern: UPDATE ... FROM + INSERT ... WHERE NOT EXISTS, come la gia'
    collaudata dbo.SpNtsBrandsUpsert. Niente MERGE e niente transazione
    esplicita: artico ha 4 trigger attivi e una transazione distribuita
    richiederebbe MSDTC.

    Se @id non esiste in dbo.Tyres: nessuna riga toccata, nessun errore.
    In UPDATE non si toccano le colonne senza sorgente in WheelsNet; ar_codalt
    e ar_hhean si aggiornano solo se la sorgente ha un valore reale.

    TEST (sola lettura, non scrive nulla):
        EXEC dbo.SpNtsArticoUpsertTyres 'ZZ00000849390', @debug = 1;

    USO:
        EXEC dbo.SpNtsArticoUpsertTyres 'ZZ00000849390';
*/
CREATE OR ALTER PROCEDURE dbo.SpNtsArticoUpsertTyres
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
            ,ar_gruppo, ar_sotgru, ar_famprod, ar_codnomc
            ,ar_pesonet, ar_pesolor
            ,ar_pnmis, ar_pnspal, ar_pndiam, ar_pnindcar, ar_pncodvel
            ,ar_pnsotgrup, ar_pnstag, ar_pndot
            ,ar_pneupresistrot, ar_pneupaderbagn, ar_pneuprumordb
            ,ar_pneuprumorliv, ar_pneuprumorliv2, ar_pnrating, ar_pndemo
        FROM dbo.ViewNtsSyncTyres
        WHERE ar_codart = @id

        UNION ALL

        SELECT
             src = 'DBTOPRUOTE'
            ,ar_codart, ar_descr, ar_desint, ar_codalt, ar_hhean
            ,ar_gruppo, ar_sotgru, ar_famprod, ar_codnomc
            ,ar_pesonet, ar_pesolor
            ,ar_pnmis, ar_pnspal, ar_pndiam, ar_pnindcar, ar_pncodvel
            ,ar_pnsotgrup, ar_pnstag, ar_pndot
            ,ar_pneupresistrot, ar_pneupaderbagn, ar_pneuprumordb
            ,ar_pneuprumorliv, ar_pneuprumorliv2, ar_pnrating, ar_pndemo
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
             a.ar_descr          = s.ar_descr
            ,a.ar_desint         = s.ar_desint
            ,a.ar_codalt         = COALESCE(s.ar_codalt, a.ar_codalt)
            ,a.ar_hhean          = COALESCE(s.ar_hhean,  a.ar_hhean)
            ,a.ar_gruppo         = s.ar_gruppo
            ,a.ar_sotgru         = s.ar_sotgru
            ,a.ar_claprov        = s.ar_claprov
            ,a.ar_famprod        = s.ar_famprod
            ,a.ar_codnomc        = s.ar_codnomc
            ,a.ar_pesonet        = s.ar_pesonet
            ,a.ar_pesolor        = s.ar_pesolor
            ,a.ar_pnmis          = s.ar_pnmis
            ,a.ar_pnspal         = s.ar_pnspal
            ,a.ar_pndiam         = s.ar_pndiam
            ,a.ar_pnindcar       = s.ar_pnindcar
            ,a.ar_pncodvel       = s.ar_pncodvel
            ,a.ar_pnsotgrup      = s.ar_pnsotgrup
            ,a.ar_pnstag         = s.ar_pnstag
            ,a.ar_pndot          = s.ar_pndot
            ,a.ar_pneupresistrot = s.ar_pneupresistrot
            ,a.ar_pneupaderbagn  = s.ar_pneupaderbagn
            ,a.ar_pneuprumordb   = s.ar_pneuprumordb
            ,a.ar_pneuprumorliv  = s.ar_pneuprumorliv
            ,a.ar_pneuprumorliv2 = s.ar_pneuprumorliv2
            ,a.ar_pnrating       = s.ar_pnrating
            ,a.ar_pndemo         = s.ar_pndemo
            ,a.ar_ultagg         = @now
            ,a.ar_oragg          = @hhmm
    FROM srvsql.dbtopruote.dbo.artico a
    INNER JOIN dbo.ViewNtsSyncTyres s
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
        ,ar_pnmis
        ,ar_pnspal
        ,ar_pndiam
        ,ar_pnindcar
        ,ar_pncodvel
        ,ar_pnsotgrup
        ,ar_pnstag
        ,ar_pndot
        ,ar_pneupresistrot
        ,ar_pneupaderbagn
        ,ar_pneuprumordb
        ,ar_pneuprumorliv
        ,ar_pneuprumorliv2
        ,ar_pnrating
        ,ar_pndemo
        ,ar_datins
        ,ar_orins
        ,ar_ultagg
        ,ar_oragg
        ,ar_datini
        ,ar_datfin
    )
    SELECT
         codditt           = s.codditt
        ,ar_codart         = s.ar_codart
        ,ar_descr          = s.ar_descr
        ,ar_desint         = s.ar_desint
        ,ar_codalt         = s.ar_codalt
        ,ar_hhean          = s.ar_hhean
        ,ar_gruppo         = s.ar_gruppo
        ,ar_sotgru         = s.ar_sotgru
        ,ar_claprov        = s.ar_claprov
        ,ar_controp        = s.ar_controp
        ,ar_controa        = s.ar_controa
        ,ar_contros        = s.ar_contros
        ,ar_famprod        = s.ar_famprod
        ,ar_codnomc        = s.ar_codnomc
        ,ar_unmis          = s.ar_unmis
        ,ar_conver         = s.ar_conver
        ,ar_qtacon2        = s.ar_qtacon2
        ,ar_codiva         = s.ar_codiva
        ,ar_prorig         = s.ar_prorig
        ,ar_paeorig        = s.ar_paeorig
        ,ar_paeorigv       = s.ar_paeorigv
        ,ar_umintra2       = s.ar_umintra2
        ,ar_pesonet        = s.ar_pesonet
        ,ar_pesolor        = s.ar_pesolor
        ,ar_pnmis          = s.ar_pnmis
        ,ar_pnspal         = s.ar_pnspal
        ,ar_pndiam         = s.ar_pndiam
        ,ar_pnindcar       = s.ar_pnindcar
        ,ar_pncodvel       = s.ar_pncodvel
        ,ar_pnsotgrup      = s.ar_pnsotgrup
        ,ar_pnstag         = s.ar_pnstag
        ,ar_pndot          = s.ar_pndot
        ,ar_pneupresistrot = s.ar_pneupresistrot
        ,ar_pneupaderbagn  = s.ar_pneupaderbagn
        ,ar_pneuprumordb   = s.ar_pneuprumordb
        ,ar_pneuprumorliv  = s.ar_pneuprumorliv
        ,ar_pneuprumorliv2 = s.ar_pneuprumorliv2
        ,ar_pnrating       = s.ar_pnrating
        ,ar_pndemo         = s.ar_pndemo
        ,ar_datins         = CAST(CAST(@now AS DATE) AS DATETIME)
        ,ar_orins          = @hhmm
        ,ar_ultagg         = @now
        ,ar_oragg          = @hhmm
        ,ar_datini         = @datIni
        ,ar_datfin         = @datFin
    FROM dbo.ViewNtsSyncTyres s
    WHERE s.ar_codart = @id
      AND NOT EXISTS (
            SELECT 1
            FROM srvsql.dbtopruote.dbo.artico a
            WHERE a.codditt   = 'TOPRUOTE'
              AND a.ar_codart = s.ar_codart
        );
END
