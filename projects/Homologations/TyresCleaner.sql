
-- Ripulisce HomologationTyres da indice carico e codice velocita
-- Es. "215/70 R16 100T,235/60 R16 104H" -> "215/70R16,235/60R16"

UPDATE hw
SET hw.[HomologationTyres] = cleaned.CleanTyres
FROM [dbo].[HomologationWheels_merged] hw
CROSS APPLY (
	SELECT CleanTyres = STRING_AGG(t.CleanTyre, ',')
	FROM (
		SELECT DISTINCT
			CleanTyre = CASE
				WHEN PATINDEX('%R[0-9][0-9]%', norm.val) > 0
				THEN LEFT(norm.val, PATINDEX('%R[0-9][0-9]%', norm.val) + 2)
				ELSE norm.val
			END
		FROM STRING_SPLIT(hw.[HomologationTyres], ',') s
		CROSS APPLY (
			SELECT val = REPLACE(REPLACE(LTRIM(RTRIM(s.value)), ' R', 'R'), 'ZR', 'R')
		) norm
		WHERE LTRIM(RTRIM(s.value)) > ''
	) t
) cleaned
WHERE hw.[HomologationTyres] > ''
	AND hw.[HomologationTyres] <> cleaned.CleanTyres
