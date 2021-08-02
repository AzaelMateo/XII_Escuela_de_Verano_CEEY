********************
version 15
clear all
set more off
cls
********************
 
/*********************************************************************************************
* Nombre archivo: 		TallerDatos_4.TransCapacitación.do
* Autor:          		Javier Valverde
* Archivos usados:     
	- ENOE_Base Global_Estatica.dta
* Archivos creados:  
	- TallerDatos_Resultados.xlsx
* Propósito:
	- Éste archivo genera y exporta los cálculos de porcentajes de trabajadores capacitados.
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
use "$root/ENOE_Base Global_Estatica.dta", clear
keep if yeartrim == 204

/* (2.2): Generamos matriz-columna de ceros que vamos a rellenar después con los resultados
y una variable contador*/
mat resultados=J(5,1,0)
gen temp = 1

/* (2.3): Obtenemos el total de la población*/
total temp [fw=fac]
scalar PEA = e(N)

/* (2.5): Definimos las Dummies de Capacitación Laxa y Estricta*/
gen capacitacion_lax = .
replace capacitacion_lax = p9_1 if p11_1 == .
replace capacitacion_lax = p9_1 if p9_1 == .
replace capacitacion_lax = 1 if p1c == 4
replace capacitacion_lax = 0 if capacitacion_lax == .

gen capacitacion_est = .
replace capacitacion_est = p9_1 if p11_1 == . & cs_p17 != 1
replace capacitacion_est = p11_1 if p9_1 == . & cs_p17 != 1
replace capacitacion_est = 1 if p1c == 4
replace capacitacion_est = 0 if capacitacion_est == .


*********************************
* (3): Cálculo de totales y porcentajes de capacitación
*********************************
/* (3.1): Porcentaje de PEA que tuvo capacitación (cálculo laxo)*/
total temp [fw=fac] if capacitacion_lax == 1
scalar total_capacitacion_lax = e(N)
mat resultados[1,1] = total_capacitacion_lax / PEA

/* (3.2): Porcentaje de PEA que no tuvo capacitación (cálculo laxo)*/
total temp [fw=fac] if capacitacion_lax == 0
scalar total_no_capacitacion_lax = e(N)
mat resultados[2,1] = total_no_capacitacion_lax / PEA

/* (3.3): Porcentaje de PEA que tuvo capacitación (cálculo estricto)*/
total temp [fw=fac] if capacitacion_est == 1
scalar total_capacitacion_est = e(N)
mat resultados[3,1] = total_capacitacion_est / PEA

/* (3.4): Porcentaje de PEA que no tuvo capacitación (cálculo estricto)*/
total temp [fw=fac] if capacitacion_est == 0
scalar total_no_capacitacion_est = e(N)
mat resultados[4,1] = total_no_capacitacion_est / PEA

/* (3.5): Promedio*/
scalar total_capacitacion_prom = (total_capacitacion_lax + total_capacitacion_est) / 2
mat resultados[5,1] = total_capacitacion_prom / PEA

*********************************
* (4): Exportar todo a Excel
*********************************
/* (4.1): Definir Archivo a modificar */
putexcel set "$root/TallerDatos_Resultados.xlsx", sheet("4. CAPACITACION") modify

/* (4.2): Insertar resultados y etiquetas*/
putexcel C2 =matrix(resultados)
putexcel B1 =("Periodo")
putexcel C1 =("2020-4")
putexcel A2 =("Cálculo Laxo")
putexcel B2 =("PEA que tuvo Capacitación (con población en sis. escolar)")
putexcel B3 =("PEA que no tuvo Capacitación (con población en sis. escolar)")
putexcel A4 =("Cálculo Estricto")
putexcel B4 =("PEA que tuvo Capacitación (sin población en sis. escolar)")
putexcel B5 =("PEA que no tuvo Capacitación (sin población en sis. escolar)")
putexcel B6 =("PEA que tuvo Capacitación (Promedio)")

