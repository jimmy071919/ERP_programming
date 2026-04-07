*&---------------------------------------------------------------------*
*& Report ZAB45_EX_D
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZAB45_EX_D.

DATA: lv_found TYPE abap_bool VALUE abap_false.
DATA: ls_emp TYPE zab45_emp.

DATA: lv_count TYPE i VALUE 0.

WRITE: / 'CLASS = A1 records:'.

SELECT * FROM zab45_emp INTO ls_emp WHERE class = 'A1'.
	WRITE: / ls_emp-emoid, ls_emp-depid, ls_emp-name, ls_emp-class, ls_emp-sex, ls_emp-birth, ls_emp-address.
	lv_found = abap_true.
	lv_count = lv_count + 1.
ENDSELECT.

IF lv_found = abap_false.
	WRITE: / 'There is no record in the table'.
ELSE.
	WRITE: / 'Table has at least one record'.
	WRITE: / 'Total rows found:', lv_count.
ENDIF.