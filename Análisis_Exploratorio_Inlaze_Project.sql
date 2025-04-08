-- Script de An醠isis Exploratorio y KPIs
-- Base de Datos: Casino_DB
-- Tabla: dbo.assetment_bookmaker_clean
-- Autor: Jaime Orejarena
-- Fecha: 2025-04-04

-- Creamos base de datos
CREATE DATABASE Casino_DB;

-- 1. Ver las primeras filas de la tabla
SELECT TOP 10 * 
FROM dbo.assetment_bookmaker_clean;

-- 2. Contar registros totales
SELECT COUNT(*) AS Total_registros
FROM dbo.assetment_bookmaker_clean;

-- 3. Contar valores nulos
SELECT 
    SUM(CASE WHEN [# Clicks] IS NULL THEN 1 ELSE 0 END) AS Clicks_null,
    SUM(CASE WHEN [# Registros IN] IS NULL THEN 1 ELSE 0 END) AS Registros_null,
    SUM(CASE WHEN [# Primer dep贸sito IN] IS NULL THEN 1 ELSE 0 END) AS PrimerDeposito_null,
    SUM(CASE WHEN [Total depositado IN] IS NULL THEN 1 ELSE 0 END) AS TotalDepositado_null,
    SUM(CASE WHEN [# Personas que apostaron IN] IS NULL THEN 1 ELSE 0 END) AS PersonasApostaron_null,
    SUM(CASE WHEN [Total apostado] IS NULL THEN 1 ELSE 0 END) AS TotalApostado_null,
    SUM(CASE WHEN [Net revenue IN] IS NULL THEN 1 ELSE 0 END) AS NetRevenue_null
FROM dbo.assetment_bookmaker_clean;

-- 4. Tratamiento de nulos
/* # Clicks (178 nulos), Significado posible del nulo: No hubo clics registrados para esa fila.
Soluci髇 recomendada: Rellenar con 0 si se asume que "nulo" = "no hubo clics". */

/* # Registros IN, # Primer dep髎ito IN, Valores nulos = 23, en ambos. Probablemente est醤 
correlacionados: si no hay registro, no hay dep髎ito. Soluci髇 recomendada: Rellenar con 0 */

/* Total depositado IN, # Personas que apostaron IN, Total apostado, Net revenue IN (43 nulos c/u)
Soluci髇 recomendada: Si estas filas corresponden a campa馻s sin conversiones, puedes asumir 0. 
Pero si te interesa hacer an醠isis solo con datos donde hubo actividad, otra opci髇 es filtrar estos 
casos en an醠isis futuros.*/

/* Reemplazamos todos los NULL con 0 en una sola instrucci髇 */
UPDATE dbo.assetment_bookmaker_clean
SET 
    [# Clicks] = ISNULL([# Clicks], 0),
    [# Registros IN] = ISNULL([# Registros IN], 0),
    [# Primer dep贸sito IN] = ISNULL([# Primer dep贸sito IN], 0),
    [Total depositado IN] = ISNULL([Total depositado IN], 0),
    [# Personas que apostaron IN] = ISNULL([# Personas que apostaron IN], 0),
    [Total apostado] = ISNULL([Total apostado], 0),
    [Net revenue IN] = ISNULL([Net revenue IN], 0);

-- Creamos una vista para filtrar por los valores mayores a 0
CREATE VIEW vw_assetment_bookmaker_con_actividad AS
SELECT *
FROM dbo.assetment_bookmaker_clean
WHERE 
    [Total depositado IN] > 0
	AND [# Primer dep贸sito IN] > 0
	AND [# Clicks] > 0
    AND [# Personas que apostaron IN] > 0
    AND [Total apostado] > 0
    AND [Net revenue IN] > 0;

-- 5. Estad韘ticas b醩icas por variable num閞ica
SELECT
    -- Clicks
    MIN([# Clicks]) AS Min_Clicks,
    MAX([# Clicks]) AS Max_Clicks,
    AVG([# Clicks]) AS Avg_Clicks,
    STDEV([# Clicks]) AS Std_Clicks,

    -- Registros
    MIN([# Registros IN]) AS Min_RegistrosIN,
    MAX([# Registros IN]) AS Max_RegistrosIN,
    AVG([# Registros IN]) AS Avg_RegistrosIN,
    STDEV([# Registros IN]) AS Std_RegistrosIN,

    -- Primer Dep髎ito
    MIN([# Primer dep贸sito IN]) AS Min_PrimerDeposito,
    MAX([# Primer dep贸sito IN]) AS Max_PrimerDeposito,
    AVG([# Primer dep贸sito IN]) AS Avg_PrimerDeposito,
    STDEV([# Primer dep贸sito IN]) AS Std_PrimerDeposito,

    -- Total depositado
    MIN([Total depositado IN]) AS Min_TotalDepositado,
    MAX([Total depositado IN]) AS Max_TotalDepositado,
    AVG([Total depositado IN]) AS Avg_TotalDepositado,
    STDEV([Total depositado IN]) AS Std_TotalDepositado,

    -- Personas que apostaron
    MIN([# Personas que apostaron IN]) AS Min_PersonasApostaron,
    MAX([# Personas que apostaron IN]) AS Max_PersonasApostaron,
    AVG([# Personas que apostaron IN]) AS Avg_PersonasApostaron,
    STDEV([# Personas que apostaron IN]) AS Std_PersonasApostaron,

    -- Total apostado
    MIN([Total apostado]) AS Min_TotalApostado,
    MAX([Total apostado]) AS Max_TotalApostado,
    AVG([Total apostado]) AS Avg_TotalApostado,
    STDEV([Total apostado]) AS Std_TotalApostado,

    -- Net Revenue
    MIN([Net revenue IN]) AS Min_NetRevenue,
    MAX([Net revenue IN]) AS Max_NetRevenue,
    AVG([Net revenue IN]) AS Avg_NetRevenue,
    STDEV([Net revenue IN]) AS Std_NetRevenue

FROM vw_assetment_bookmaker_con_actividad;

-- 6. Comparativa entre Periodos Consecutivos (mes a mes)
WITH kpi_mensual AS (
    SELECT 
        Periodo AS Mes,
        SUM([Net revenue IN]) AS Net_Revenue
    FROM vw_assetment_bookmaker_con_actividad
    GROUP BY Periodo
)
SELECT 
    Mes,
    Net_Revenue,
    LAG(Net_Revenue) OVER (ORDER BY Mes) AS Net_Revenue_Previous,
    ROUND(Net_Revenue - LAG(Net_Revenue) OVER (ORDER BY Mes), 2) AS Diferencia_Mes,
    ROUND(100.0 * (Net_Revenue - LAG(Net_Revenue) OVER (ORDER BY Mes)) / 
        NULLIF(LAG(Net_Revenue) OVER (ORDER BY Mes), 0), 2) AS Variacion_Porcentual
FROM kpi_mensual;





