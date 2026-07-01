# Ayuda CUSUM

**Digital Dashboard**  
Uso e interpretación de las salidas CUSUM en el Digital Dashboard  
Revisión de documentación: junio de 2026  
Idioma: Español

---

# 1. Alcance en el Dashboard

El componente CUSUM vigila recuentos semanales para detectar aumentos sostenidos sobre un valor esperado. Usa los archivos activos, nivel geográfico, ubicaciones CUSUM, período de detección y parámetros seleccionados.

> **Comportamiento de Locations.** El selector Locations limita las unidades CUSUM. Actualmente no filtra los mapas Geospatial.

Los controles de año y semana del mapa corresponden a Geospatial. CUSUM usa la historia semanal reciente requerida por el período de detección y las reglas de cobertura.


# 2. Configurar CUSUM

| Control | Significado |
| --- | --- |
| Geographic Level | Nivel administrativo usado para crear unidades CUSUM independientes. |
| Locations | Unidades incluidas; vacío incluye todas las disponibles del nivel. |
| Detection Period | Número reciente de semanas de vigilancia. |
| Expected Frequency | Recuento esperado automático por unidad o tasa semanal manual por 100.000 convertida usando la población de cada unidad. La población es obligatoria en modo manual. |
| Target ARL0 | Longitud media en control utilizada para recomendar h. |
| Relative Risk | Aumento que se desea detectar; se usa para calcular k. |
| Calculated k | Valor de referencia calculado con el esperado y el riesgo relativo. |
| h Threshold | Umbral de alarma; valores mayores suelen producir menos alarmas. |

1. Cargue y active los archivos.
2. Elija nivel y Locations opcionales.
3. Configure CUSUM.
4. Seleccione Run Analysis.
5. Use Display para elegir gráficos, tablas, fuente, decimales y cambios reactivos de presentación.

> **Run Analysis.** Cambios de archivos, nivel o Locations requieren ejecutar nuevamente. Display puede reorganizar resultados ya calculados.


# 3. Salidas y descargas

- Resumen de alarmas: mapa de calor por unidad y semana.
- Serie observado/esperado: compara recuentos y línea base.
- Proceso CUSUM: muestra acumulación y umbral h.
- Resultados semanales: valores, estadístico, alarma y parámetros.
- Referencia por unidad: esperados e información de referencia.
- Prepared CUSUM data: conjunto limpio, agregado, sin solapamientos y con brechas completadas.

Los botones de descarga aparecen cuando existe el resultado. Los CSV conservan precisión completa aunque la tabla muestre menos decimales.


# 4. Interpretación responsable

Una alarma indica que la desviación positiva acumulada alcanzó h. Es una señal temprana, no prueba de brote ni conclusión causal.

- Confirme completitud y que los ceros agregados representen semanas realmente sin casos.
- Revise archivos activos y manejo de duplicados.
- Revise cambios de definición, acceso a laboratorio, intensidad de vigilancia o demoras.
- Compare unidades vecinas y mapas cuando corresponda.
- Documente archivos, filtros, método esperado, RR, k y h al escalar.

> **Interpretación.** Una semana alta aislada puede no alarmar; elevaciones moderadas repetidas pueden acumularse.


# 5. Solución de problemas

| Problema | Qué revisar |
| --- | --- |
| Sin salida CUSUM | Archivos activos, Run Analysis y salidas CUSUM habilitadas en Display. |
| Locations parece ignorado | Locations afecta CUSUM, no los mapas. |
| Advertencia de cobertura | Revise Prepared Data y semanas observadas antes del relleno con ceros. |
| Línea base manual incorrecta | Ingrese la tasa semanal esperada por 100.000 habitantes. La app convierte esa tasa en conteos esperados semanales para cada unidad de análisis usando la población. |
| Display cambió pero no los datos | Display cambia presentación; filtros estructurales requieren Run Analysis. |
| CSV difiere de decimales visibles | La tabla está formateada; la descarga conserva precisión. |

