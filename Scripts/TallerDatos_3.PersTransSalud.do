********************
version 15
clear all
set more off
cls
********************
 
/*********************************************************************************************
* Nombre archivo: 		TallerDatos_3.PersTransSalud.do
* Autor:          		Javier Valverde
* Archivos usados:     
	- ENOE_Base Global_Dinamica.dta
* Archivos creados:  
	- RT_BoletinTrimestral_Datos.xlsx
* Propósito:
	- Éste archivo genera y exporta los cálculos de persistencia y transiciones de salud.
	En particular, busca encontrar el porcentaje de la PEA que mantuvo acceso a los servicios,
	que no tenía y los obtuvo, que tenía pero los perdió, y que se mantuvo sin acceso.
*********************************************************************************************/

******************************
* (1): Definimos directorios *
******************************
/* (1.1): Definimos el directorio en donde se encuentra la base de datos que utilizaremos
y donde estará el excel que exportemos. */
gl root = "/Users/miusuario/midirectorio"
gl bases = "$root/Bases ENOE"


*********************************
* (2): Operaciones preliminares *
*********************************
/* (2.1): Seleccionamos base de datos a utilizar y nos quedamos solo con el año deseado*/
use "$root/ENOE_Base Global_Dinamica.dta", clear
keep if yeartrim == 204

/* (2.2): Tiramos las observaciones de los que  no especifican si tienen o no 
servicios de salud y de quienes tienen acceso a otras instituciones de atención médica */
drop if imssissste1 == 3 | imssissste1 == 5
drop if imssissste2 == 3 | imssissste2 == 5

/* (2.3): Generamos matriz-columna de ceros que vamos a rellenar después con los resultados*/
mat resultados=J(4,1,0)

/* (2.4): Obtenemos el total de la población*/
total temp [fw=factor]
scalar PEA = e(N)

/* (2.5): Definimos las Dummies de afiliación*/
gen afiliacion1 = .
replace afiliacion1 = 0 if (imssissste1 == 0 | imssissste1 == 4)
replace afiliacion1 = 1 if (imssissste1 == 1 | imssissste1 == 2)

gen afiliacion2 = .
replace afiliacion2 = 0 if (imssissste2 == 0 | imssissste2 == 4)
replace afiliacion2 = 1 if (imssissste2 == 1 | imssissste2 == 2)

/* (2.4): Definimos la variable categórica para cada tipo de transición*/
gen cambioafiliacion = .
replace cambioafiliacion = 4 if (afiliacion2 == 1 & afiliacion1 == 1)
replace cambioafiliacion = 3 if (afiliacion2 == 1 & afiliacion1 == 0)
replace cambioafiliacion = 2 if (afiliacion2 == 0 & afiliacion1 == 1)
replace cambioafiliacion = 1 if (afiliacion2 == 0 & afiliacion1 == 0)

*********************************
* (3): Cálculo de totales y porcentajes de transiciones
*********************************
/* (3.1): Porcentaje de PEA que mantuvo servicios de salud*/
total temp [fw=factor] if cambioafiliacion == 4
scalar pea_mantuvo_ss = e(N)
mat resultados[1,1] = pea_mantuvo_ss / PEA

/* (3.2): Porcentaje de PEA que obtuvo servicios de salud*/
total temp [fw=factor] if cambioafiliacion == 3
scalar pea_obtuvo_ss = e(N)
mat resultados[2,1] = pea_obtuvo_ss / PEA

/* (3.3): Porcentaje de PEA que perdió servicios de salud*/
total temp [fw=factor] if cambioafiliacion == 2
scalar pea_perdio_ss = e(N)
mat resultados[3,1] = pea_perdio_ss / PEA

/* (3.4): Porcentaje de PEA que se mantuvo sin servicios de salud*/
total temp [fw=factor] if cambioafiliacion == 1
scalar pea_mantuvo_sin_ss = e(N)
mat resultados[4,1] = pea_mantuvo_sin_ss / PEA


*********************************
* (4): Exportar todo a Excel
*********************************
/* (4.1): Definir Archivo a modificar */
putexcel set "$root/TallerDatos_Resultados.xlsx", sheet("3. Transiciones SALUD") modify

/* (4.2): Insertar resultados y etiquetas*/
putexcel B2 =matrix(resultados)
putexcel A1 =("Periodo")
putexcel B1 =("2020-4")
putexcel A2 =("PEA que mantuvo servicios de salud")
putexcel A3 =("PEA que obtuvo servicios de salud")
putexcel A4 =("PEA que perdió servicios de salud")
putexcel A5 =("PEA que se mantuvo sin servicios de salud")

