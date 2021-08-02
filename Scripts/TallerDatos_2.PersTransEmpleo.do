********************
version 15
clear all
set more off
cls
********************
 
/*********************************************************************************************
* Nombre archivo: 		TallerDatos_2.PersTransEmpleo.do
* Autor:          		Javier Valverde
* Archivos usados:     
	- ENOE_Base Global_Dinamica.dta
* Archivos creados:  
	- RT_BoletinTrimestral_Datos.xlsx
* Propósito:
	- Éste archivo genera y exporta los cálculos de persistencia y transiciones a y de 
	  diferentes tipos de empleo.
*********************************************************************************************/

******************************
* (1): Definimos directorios *
******************************
/* (1.1): Definimos el directorio en donde se encuentra la base de datos que utilizaremos
y donde estará el excel que exportemos. */
gl root = "/Users/miusuario/midirectorio"


*********************************
* (2): Operaciones preliminares *
*********************************
/* (2.1): Seleccionamos base de datos a utilizar y nos quedamos solo con el año deseado*/
use "$root/ENOE_Base Global_Dinamica.dta", clear
keep if yeartrim == 204

/* (2.2): Generamos matriz-columna de ceros que vamos a rellenar después con los resultados
y generamos una variable contador*/
mat resultados=J(6,1,0)
gen temp = 1

/* (2.3): Definimos las Dummies de empleo y desempleo inicial y final*/
gen ERini = 1 if (clase3ini == 1 | clase3ini == 3 | clase3ini == 4)
gen ERfin = 1 if (clase3fin == 1 | clase3fin == 3 | clase3fin == 4)
replace ERini = 0 if ERini == .
replace ERfin = 0 if ERfin == .

gen DENRini = 1 if (clase2ini == 2 | clase3ini == 2)
gen DENRfin = 1 if (clase2fin == 2 | clase3fin == 2)

/* (2.4): Definimos el escalar de total de la PEA*/
total temp [fw=factor]
scalar PEA = e(N)


*********************************
* (3): Cálculo de totales y porcentajes con ER y DENR
*********************************
/* (3.1): Porcentaje de PEA con Empleo Remunerado */
total temp [fw=factor] if ERini == 1
scalar ER = e(N)
mat resultados[1,1] = ER / PEA

/* (3.2): Porcentaje de PEA en Desempleo/Empleo No Remunerado*/
total temp [fw=factor] if DENRini == 1
scalar DENR = e(N)
mat resultados[2,1] = DENR / PEA

*********************************
* (4): Cálculo de totales y porcentajes de Transiciones y Persistencias
*********************************
/* (4.1): Porcentaje de PEA que Obtuvo Empleo*/
total temp [fw=factor] if (DENRini == 1 & ERfin == 1)
scalar obtuvo_empleo = e(N)
mat resultados[3,1] = obtuvo_empleo / PEA

/* (4.2): Porcentaje de PEA que Mantuvo Empleo*/
total temp [fw=factor] if (ERini == 1 & ERfin == 1)
scalar mantuvo_empleo = e(N)
mat resultados[4,1] = mantuvo_empleo / PEA

/* (4.3): Porcentaje de PEA que Perdió Empleo */
total temp [fw=factor] if (ERini == 1 & DENRfin == 1)
scalar perdio_empleo = e(N)
mat resultados[5,1] = perdio_empleo / PEA

/* (4.4): Porcentaje de PEA que Mantuvo Desempleo */
total temp [fw=factor] if (DENRini == 1 & DENRfin == 1)
scalar mantuvo_desempleo = e(N)
mat resultados[6,1] = mantuvo_desempleo / PEA



*********************************
* (5): Exportar todo a Excel
*********************************
/* (5.1): Definir Archivo a modificar */
putexcel set "$root/TallerDatos_Resultados.xlsx", sheet("2. Transiciones EMPLEO") modify

/* (5.2): Insertar resultados y etiquetas*/
putexcel B2 =matrix(resultados)
putexcel A1 =("Periodo")
putexcel B1 = ("2020-4")
putexcel A2 =("PEA con ER")
putexcel A3 =("PEA en DENR")
putexcel A4 =("PEA que obtuvo ER")
putexcel A5 =("PEA que mantuvo ER")
putexcel A6 =("PEA que perdió ER")
putexcel A7 =("PEA que se mantuvo DENR")

