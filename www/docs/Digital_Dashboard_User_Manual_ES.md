# Manual de Usuario

**Digital Dashboard**  
Flujo unificado de análisis CUSUM y geoespacial  
Revisión de documentación: junio de 2026  
Idioma: Español

---

# 1. Qué hace el Dashboard

Digital Dashboard combina CUSUM RAP y Geospatial RAP en una sola interfaz. Una carga y filtros compartidos alimentan gráficos de alerta, mapas, tablas, datos preparados y descargas.

| Página | Propósito |
| --- | --- |
| Home | Descripción y flujo recomendado. |
| Dashboard | Carga, filtros, parámetros, ejecución, salidas y datos preparados. |
| Display | Salidas visibles, diseño, ubicación de tablas, fuente, decimales y actualización reactiva. |
| Help | Resumen y enlaces de documentación. |

> **Dos comportamientos de ubicación.** Locations limita las unidades CUSUM. El flujo Geospatial actual sigue mapeando todas las unidades disponibles del nivel y ventana seleccionados.


# 2. Archivos de entrada y gestión

Use archivos delimitados compatibles con API-POP. Aunque el selector muestra varias extensiones, el importador provisto lee texto CSV y detecta coma o punto y coma. CSV es el formato confiable de esta versión.

| Columna | Requisito | Significado |
| --- | --- | --- |
| country | Sí en la validación actual | Valor de país. El código actual fija active_country en Argentina. |
| year | Sí | Año epidemiológico, 2000-2100. |
| week | Sí | Semana epidemiológica, 1-53. |
| level1..level4 | Al menos una | Jerarquía geográfica usada por el nivel configurado. |
| n_cases | Sí | Casos observados; alias cases, case_count, count, n. |
| population | Para mapas | Denominador; alias n_population, pop, denominator. |

Cada archivo queda en la sesión con filas, columnas, rango epidemiológico, fecha y tamaño. Los nuevos archivos están activos por defecto.

- Manage files permite activar o desactivar.
- Remove inactive files elimina los no seleccionados de la sesión.
- Clear all files elimina datos y resultados de la sesión.
- Cambiar archivos activos invalida resultados; ejecute nuevamente.

> **Sin escritura en base.** El Dashboard actual analiza datos de la sesión y no los agrega a una base epidemiológica persistente.


# 3. Filtros compartidos y CUSUM

| Control | Efecto |
| --- | --- |
| Geographic Level | Nivel usado por ambos motores. |
| Detection Period | Semanas recientes para CUSUM; 8-260, predeterminado 52. |
| Locations | Todas seleccionadas por defecto; actualmente afecta solo CUSUM. |
| Year | Año para mapas y semanas disponibles. |
| Map Time Window | Semana única o rango inclusivo; el rango fuerza al menos dos semanas cuando es posible. |
| Expected Frequency | Línea automática por unidad o recuento semanal manual. |
| Target ARL0 | Usado para h recomendado. |
| Relative Risk | Usado para calcular k. |
| h Threshold | Umbral de alarma. |
| Run Analysis | Actualiza CUSUM y Geospatial. |

Calculated k y recommended h aparecen cuando hay información suficiente.

> **Ejecución obligatoria.** Cambios en datos activos, nivel o Locations requieren Run Analysis. Display puede cambiarse antes o después.


# 4. Configurar Display

Puede configurarse antes del primer análisis o después. Modifica la presentación, no los datos.

| Opción | Comportamiento |
| --- | --- |
| Visible outputs | Tres gráficos CUSUM y dos mapas. |
| Output layout | Una o dos columnas. |
| Results table location | Dentro de Output o en Output Table. |
| Display font size | Small, Medium, Large, Extra large. |
| Decimal places | 0-6 en pantalla; CSV sin cambios. |
| Reactive display | Tras una ejecución, actualiza automáticamente parámetros CUSUM y año/semana/modo del mapa. |

No aplica automáticamente cambios de archivos, nivel o ubicaciones; estos requieren Run Analysis.


# 5. Ejecutar y revisar

1. Cargue y active CSV.
2. Configure nivel, ubicaciones, período, año y ventana.
3. Configure CUSUM.
4. Configure Display si corresponde.
5. Seleccione Run Analysis.
6. Revise Output, Prepared Data y Output Table opcional.

## Salidas CUSUM

- Mapa de calor de alarmas.
- Serie observada/esperada.
- Proceso CUSUM y umbral.
- Tablas semanal y de referencia.

## Salidas Geospatial

- Mapa de prevalencia de todas las unidades coincidentes.
- Mapa LISA.
- Resumen Global Moran cuando es posible.
- Tabla de resultados.

## Prepared Data

Incluye CUSUM prepared data y Active standardized data, con descargas CSV y filtro Search by.

> **Descargas.** Los botones aparecen cuando existe el resultado. La imagen del mapa depende de paquetes opcionales.


# 6. Uso de tiempo y geografía

| Dimensión | CUSUM | Geospatial |
| --- | --- | --- |
| Locations | Usa las ubicaciones seleccionadas. | Usa todas las unidades del nivel. |
| Detection period | Ventana CUSUM reciente. | No se usa. |
| Year | Usa el historial semanal disponible, no el selector de mapa. | Filtra al año seleccionado. |
| Week selection | No usa Map Time Window. | Usa semana o rango. |
| Population | Opcional. | Obligatoria. |
| Geographic level | Construye unidades CUSUM. | Carga la capa configurada. |

> **Evite confusión.** No suponga que Locations recorta los mapas; actualmente los mapas comparan todo el nivel.


# 7. Interpretación y exportaciones

- Las alarmas CUSUM requieren revisión.
- Los mapas dependen de numerador y denominador.
- Moran Global resume el patrón general y LISA los patrones locales.
- Display no cambia valores analíticos.

| Exportación | Contenido |
| --- | --- |
| CUSUM PNG | Mapa de calor, serie o proceso. |
| Mapa PNG | Mapa actual cuando hay captura instalada. |
| CUSUM CSV | Resultados semanales o referencia. |
| Geospatial CSV | Resultados espaciales. |
| Prepared CUSUM CSV | Datos usados por CUSUM. |
| Active Standardized CSV | Datos activos normalizados y con códigos ajustados. |


# 8. Solución de problemas

| Problema | Qué revisar |
| --- | --- |
| XLSX/TSV no carga | Convierta a CSV con coma o punto y coma. |
| CUSUM funciona pero mapas fallan | Población, GeoPackage, ID, nivel o semanas. |
| Mapas muestran todas las áreas | Comportamiento actual; Locations solo limita CUSUM. |
| El rango se ajusta a dos semanas | El modo Range exige al menos dos cuando es posible. |
| Salidas desactualizadas | Ejecute tras cambios de archivos, nivel o ubicaciones. |
| Sin descarga de mapa | Faltan paquetes opcionales. |
| Enlace falla en Linux | Use nombres exactos sensibles a mayúsculas del paquete actualizado. |

> **Información para escalar.** Incluya archivos activos, filtros, parámetros CUSUM, Display, error exacto y cuál motor falló.


# 9. Glosario

| Término | Significado |
| --- | --- |
| Archivo activo | Archivo incluido en los datos combinados. |
| Datos normalizados | Columnas tras alias, conversión, limpieza y relleno de códigos. |
| Reactive display | Reejecución automática después de un primer resultado. |
| Output Table | Pestaña opcional para tablas separadas. |
| Prepared CUSUM data | Conjunto semanal agregado/completado para CUSUM. |
| Map Time Window | Semana o rango usado solo por Geospatial. |

