# Ayuda Geospatial

**Digital Dashboard**  
Uso e interpretación de mapas en el Digital Dashboard  
Revisión de documentación: junio de 2026  
Idioma: Español

---

# 1. Alcance en el Dashboard

El componente Geospatial agrega casos y población para el nivel y ventana temporal seleccionados, une los resultados con la capa GeoPackage configurada y produce prevalencia y conglomerados espaciales.

> **Se mapean todas las unidades.** El Dashboard actual representa todas las unidades disponibles del nivel y período. Locations actualmente afecta solo CUSUM.

La población es obligatoria porque la prevalencia se calcula como casos divididos por población y multiplicados por 100.000 en la configuración actual.


# 2. Configurar los mapas

| Control | Significado |
| --- | --- |
| Geographic Level | Nivel administrativo y capa espacial. |
| Year | Año epidemiológico del mapa. |
| Single Week | Usa una semana. |
| Week Range | Agrega casos en un intervalo inclusivo de al menos dos semanas cuando es posible. |
| Population | Denominador obligatorio; valores semanales repetidos se deduplican. |
| Run Analysis | Reconstruye datos y estadísticas espaciales. |

1. Active los archivos requeridos.
2. Elija Geographic Level.
3. Seleccione año y Single Week o Week Range.
4. Seleccione Run Analysis.
5. Use Display para mapas, tabla, diseño, fuente y decimales.

> **Coincidencia de identificadores.** Los códigos CSV deben coincidir con los identificadores espaciales tras normalización y relleno con ceros.


# 3. Leer las salidas

El mapa de prevalencia muestra casos por 100.000 para cada unidad coincidente. La leyenda permanece visible y los popups muestran nombre, identificador, casos, población, prevalencia, categoría LISA y p-valor cuando corresponde.

Moran Global resume autocorrelación espacial. Un valor positivo significativo sugiere agrupación de valores similares; uno negativo sugiere disimilitud vecina. No identifica las unidades locales.

| Categoría LISA | Significado |
| --- | --- |
| High-High | Unidad alta rodeada de vecinas altas; posible punto caliente. |
| Low-Low | Unidad baja rodeada de vecinas bajas; posible punto frío. |
| High-Low | Unidad alta entre vecinas bajas; valor atípico. |
| Low-High | Unidad baja entre vecinas altas; valor atípico inverso. |
| Not Significant | Sin asociación local bajo la regla actual. |

La tabla contiene identificadores, nombres, casos, población, semanas, prevalencia, LISA y p-valor. Prepared Data registra agregación, normalización, unión y cálculo espacial.


# 4. Interpretación responsable

- Moran y LISA describen asociación, no causalidad.
- Las clasificaciones dependen de vecindad, unidades disponibles, calidad y ventana temporal.
- Poblaciones pequeñas pueden generar prevalencias inestables.
- Un conglomerado puede reflejar notificación, acceso, movilidad, estructura poblacional o práctica local.
- Compare mapas con CUSUM, denominadores e información epidemiológica local.

> **Mapas de rango.** En modo rango se suman casos y se deduplican registros repetidos de población antes de agregar el denominador.


# 5. Solución de problemas

| Problema | Qué revisar |
| --- | --- |
| Mapa vacío o faltan unidades | Datos activos, población, GeoPackage, capa e identificadores. |
| Locations no filtra mapas | Es el comportamiento actual; se usan todas las unidades del nivel. |
| Sin Moran o LISA | Pocas unidades, varianza cero, vecindad ausente o prueba fallida. |
| Prevalencia inesperada | Deduplicación de población, ventana y multiplicador. |
| Sin descarga de mapa | Pueden faltar paquetes de captura; los CSV aún pueden funcionar. |
| Display cambió pero datos no | Cambios estructurales requieren Run Analysis. |

