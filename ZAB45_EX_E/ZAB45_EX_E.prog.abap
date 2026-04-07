*&---------------------------------------------------------------------*
*& Report ZAB45_EX_E
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zab45_ex_e.

" 宣告 work area 和 internal table
DATA: wa_emp TYPE zab45_emp.
DATA: it_emp TYPE TABLE OF zab45_emp.
DATA: it_acc01 TYPE TABLE OF zab45_emp.

" 將 table 內容逐筆複製到 internal table
SELECT * FROM zab45_emp INTO wa_emp.
	IF wa_emp-depid = 'ACC01'.
		APPEND wa_emp TO it_acc01.
	ELSE.
		APPEND wa_emp TO it_emp.
	ENDIF.
ENDSELECT.

" 印出 internal table 所有內容

WRITE: / 'ACC01 部門員工：'.
LOOP AT it_acc01 INTO wa_emp.
	WRITE: / wa_emp-emoid, wa_emp-depid, wa_emp-name, wa_emp-class, wa_emp-sex, wa_emp-birth, wa_emp-address.
ENDLOOP.

WRITE: / '其他部門員工：'.
LOOP AT it_emp INTO wa_emp.
	WRITE: / wa_emp-emoid, wa_emp-depid, wa_emp-name, wa_emp-class, wa_emp-sex, wa_emp-birth, wa_emp-address.
ENDLOOP.