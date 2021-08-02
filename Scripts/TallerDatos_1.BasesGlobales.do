********************
version 15
clear all
set more off
cls
********************
 
/**********************************************************************************************************************************
* Fecha: 				24/Julio/2021
* Nombre archivo: 		TallerDatos_1.BasesGlobales.do
* Autor:          		Azael Mateo		
* Archivos creados:  
	- Bases de datos de sitio web INEGI
	- Base global estática
	- Base global dinámica
* Propósito:
	- Éste archivo baja y comprime las bases de datos de la ENOE del 1T 2020 y la ENOE_N del 4T 2020 para construir dos bases de 
	  datos (global estática y global dinámica) tipo panel de las tablas de datos "Sociodemográfico", "Cuestionario de ocupación y 
	  empleo parte l" y "Cuestionario de ocupación y empleo parte ll".
* Consideraciones:
	- La pandemia provocó un rediseño en el levantamiendo de la ENOE, es por ello que se realiza un tratamiento por separado a cada
	  trimestre. Una vez homologadas nuestras variables de interés, procedemos a la construcción de las bases globales.
	- La base de datos "estática" se limita a unir todas las bases de datos disponibles, mientras que la base de datos "dinámica" 
	  compara los resultados de ciertas variables para personas con entrevistas disponibles a lo largo de un año.
	- La base "estática" tiene a la población completa, pues borrar la PEA eliminaría la posibilidad de hacer un análisis de la 
	  transición del empleo a la PNEA.
***********************************************************************************************************************************/


**********************************
* (1): Definición de directorios *
**********************************

/* (1.1): Definimos el directorio en donde guardaremos las bases de datos. */
gl root = "E:\Azael Personal\Documentos\CEEY\10. Verano 2021\XII Escuela de Verano"
cap mkdir "$root/Bases ENOE"
gl bases = "$root/Bases ENOE"


*****************************************
* (2): Bajar y comprimir bases de datos *
*****************************************

/* (2.1): ENOE 1T 2020. */
disp "Trabajando para bases año 2020 trimestre 1"

* Creamos directorios y bajamos archivos:
capture mkdir "$bases/2020trim1_dta"
cd "$bases/2020trim1_dta"

* Revisamos si existen bases de datos para no volver a bajar
capture confirm file "COE1T120'.dta"
if _rc!=0 {	
	copy "https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/microdatos/2020trim1_dta.zip"  2020trim1_dta.zip
			
	* Revisamos tamaño de archivo para ver si existe el año indicado. Si no existe, paramos, si existe, seguimos:
	qui checksum 2020trim1_dta.zip
	if r(filelen)/1000000 < 1 {
		disp "Aún no existen archivos para el año 2020 trimestre 1"
		break
	}
	else {
		unzipfile	2020trim1_dta.zip
		
		******* COMPRESIÓN DE BASES *******
		* Primero base COE1T Y COE2T
		use "COE1T120.dta", clear
		rename *, lower
		qui compress
		save, replace
		use "COE2T120.dta", clear
		rename *, lower
		qui compress
		save, replace

		* Segundo base hogar
		use "HOGT120.dta", clear
		rename *, lower
		qui compress
		save, replace

		* Tercero base sociodemográficos
		use "SDEMT120.dta", clear
		rename *, lower
		qui compress
		save, replace

		* Por último base de vivienda
		use "VIVT120.dta", clear
		rename *, lower
		qui compress
		save, replace
	}
	* Por último, se borra el archivo zip:
	erase 2020trim1_dta.zip 
}


/* (2.2): ENOE_N 4T 2020. */
disp "Trabajando para bases año 2020 trimestre 4"

* Creamos directorios y bajamos archivos:
capture mkdir "$bases/2020trim4_dta"
cd	"$bases/2020trim4_dta"
		
* Revisamos si existen bases de datos para no volver a bajar
capture confirm file "COE1T420.dta"
if _rc!=0 {	
	copy "https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/microdatos/enoe_n_2020_trim4_dta.zip"  enoe_n_2020_trim4_dta.zip
		
	* Revisamos tamaño de archivo para ver si existe el año indicado. Si no existe, paramos, si existe, seguimos:
	qui checksum enoe_n_2020_trim4_dta.zip
	if r(filelen)/1000000 < 1 {
		disp "Aún no existen archivos para el año 2020 trimestre 4"
		break
	}
	else {
		unzipfile	enoe_n_2020_trim4_dta.zip
		
		******* COMPRESIÓN DE BASES *******
		* Primero base COE1T Y COE2T
		use "enoen_coe1t420.dta", clear
		rename *, lower
		qui compress
		save "COE1T420.dta", replace
		erase enoen_coe1t420.dta
		use "enoen_coe2t420.dta", clear
		rename *, lower
		qui compress
		save "COE2T420.dta", replace
		erase enoen_coe2t420.dta
	
	    * Segundo base hogar
		use "enoen_hogt420.dta", clear
		rename *, lower
		qui compress
		save "HOGT420.dta", replace
		erase enoen_hogt420.dta

		* Tercero base sociodemográficos
		use "enoen_sdemt420.dta", clear
		rename *, lower
		qui compress
		save "SDEMT420.dta", replace
		erase enoen_sdemt420.dta

		* Por último base de vivienda
		use "enoen_vivt420.dta", clear
		rename *, lower
		qui compress
		save "VIVT420.dta", replace
		erase enoen_vivt420.dta
	}
	* Por último, se borra el archivo zip:
	erase enoe_n_2020_trim4_dta.zip
}

*****************************
* (3): Base global estática *
*****************************

/* (3.1): Creamos una base unificada del primer trimestre, haciendo un merge de SDEM, COE1 y COE2. */
cd "$root"
use "$bases/2020trim1_dta/SDEMT120.dta", clear

* Fusionamos la tabla Sociodemográfica con el Cuestionario de ocupación y empleo parte l
qui merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$bases/2020trim1_dta/COE1T120.dta", force
keep if _merge==3
keep r_def loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog h_mud n_ent per n_ren c_res ///
	par_c sex eda nac_dia nac_mes nac_anio l_nac_c ingocup per fac cs_p13_1 cs_p13_2 cs_p17  clase* imssissste p1 p1c salario

* Ahora fusionamos con el Cuestionario de ocupación y empleo parte 2
qui merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$bases/2020trim1_dta/COE2T120.dta", force
keep if _merge==3
keep r_def loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog h_mud n_ent per n_ren c_res ///
	par_c sex eda nac_dia nac_mes nac_anio l_nac_c ingocup per fac cs_p13_1 cs_p13_2 cs_p17  clase* imssissste p1 p1c p11_1 salario p6c p6b2 p6_9 p6a3

* Una vez removidas las variables que no nos interesan, guardamos nuestra base unificada
save "$root/primertrim.dta", replace

/* (3.2): Hacemos lo propio para el cuarto trimestre. */
use "$bases/2020trim4_dta/SDEMT420.dta", clear
			
* Renombramos variables trimestrales
rename est_d_tri est_d
rename t_loc_tri t_loc
rename fac_tri fac
			
* Fusionamos la tabla Sociodemográfica con el Cuestionario de ocupación y empleo parte l
qui merge 1:1 cd_a ent con v_sel tipo mes_cal ca n_hog h_mud n_ren using "$bases/2020trim4_dta/COE1T420.dta"
keep if _merge==3
keep r_def loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel tipo mes_cal ca n_hog h_mud n_ent per n_ren c_res par_c ///
	sex eda nac_dia nac_mes nac_anio l_nac_c ingocup per fac cs_p13_1 cs_p13_2 cs_p17  clase* imssissste p1 p1c salario
	
* Ahora fusionamos con el Cuestionario de ocupación y empleo parte 2
qui merge 1:1 cd_a ent con v_sel tipo mes_cal ca n_hog h_mud n_ren using "$bases/2020trim4_dta/COE2T420.dta"
keep if _merge==3
keep r_def loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel tipo n_hog h_mud n_ent per n_ren c_res par_c ///
	sex eda nac_dia nac_mes nac_anio l_nac_c ingocup per fac cs_p13_1 cs_p13_2 cs_p17  clase* imssissste p1 p1c p9_1 salario /// 
	p6c p6b2 p6_9 p6a3

save "tercertrim.dta", replace

/* (3.3): Ya con serie de bases pequeñas procedemos a juntar todas en una base total. */
use "primertrim.dta", clear
append using "tercertrim.dta", force

/* (3.4): Generamos variables importantes. */
* Identificador único
egen foliop = concat(cd_a ent con v_sel n_hog h_mud n_ren sex nac_dia nac_anio nac_mes)
egen folioh = concat(cd_a ent con v_sel n_hog h_mud n_ren)

* Clasificador de tipo de localidad
gen rururb = cond(t_loc>=1 & t_loc<=3,0,1) 
label define ru 0 "Urbano" 1 "Rural" 
label values rururb ru 

* Variable año-trimestre y la misma con lag de un año
gen year = substr(string(per),2,2)
gen trim = substr(string(per),1,1)
egen yeartrim = concat(year trim)
destring yeartrim, replace
gen int yeartrim_lag = .
replace yeartrim_lag = 192 if yeartrim == 201
replace yeartrim_lag = 201 if yeartrim == 204
egen base = group(yeartrim)

* Variable carácter de año, mes y fecha
gen anio = "20" + year
destring trim, replace
gen mes = string(trim*3)
replace mes = "0" + mes if strlen(mes)==1
generate str fecha = anio + "-" + mes + "-01"
compress

/* (3.4): Guardamos base global estática. */
save "ENOE_Base Global_Estatica.dta", replace

*****************************
* (4): Base global dinámica *
*****************************

/* (4.1): Limpieza de datos. */
* Tiramos las entrevistas intermedias
drop if n_ent != 1 & n_ent != 4							
	
* Mantenemos solo a aquellos que tienen entrevista en primer y en cuarto trimestre.
qui duplicates tag foliop, gen(dup)				
qui keep if dup == 1									

* Guardamos base temporal
save "temp.dta", replace
	
/* (4.2): Base dinámica 1T. */
* Nos quedamos solo con las observaciones de cuatro trimestres antes.
qui keep if yeartrim == 201
rename ingocup ingocup1
rename imssissste imssissste1
rename clase1 clase1ini
rename clase2 clase2ini
rename clase3 clase3ini

* Guardamos base temporal a
save "tempa.dta", replace
	
/* (4.2): Base dinámica 1T. */
use "temp.dta", clear
	
* Nos quedamos solo con las observaciones del trimestre actual.
qui keep if yeartrim == 204
rename ingocup ingocup2
rename imssissste imssissste2
rename clase1 clase1fin
rename clase2 clase2fin
rename clase3 clase3fin
rename fac factor

capture drop _merge
	
/* (4.3): Juntamos bases. */
qui merge m:m foliop using "tempa.dta" 
qui keep if _merge == 3
qui drop dup											

/* (4.4): Tiramos a ausentes definitivos, nos quedamos con rango de edad de PEA, entrevistas completas y PEA */
drop if r_def != 0
drop if c_res == 2
drop if eda < 12 | eda == 99
keep if clase1ini == 1
compress

/* (4.5): Guardamos base global dinámica. */
save "ENOE_Base Global_Dinamica.dta", replace

* Eliminamos bases temporales
erase "primertrim.dta" 
erase "tercertrim.dta" 
erase "temp.dta" 
erase "tempa.dta"
shell rmdir "Bases ENOE" /s /q

exit





