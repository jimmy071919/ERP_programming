*&---------------------------------------------------------------------*
*& Report ZAB45_EX_F
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zab45_ex_f.

DATA: n TYPE i VALUE 6.

PERFORM sub_value USING n.
PERFORM sub_ref CHANGING n.
WRITE: / 'n =', n.

" 副程式1：call by value

FORM sub_value USING p_n TYPE i.
  	DATA: lv_square TYPE i.
  	lv_square = p_n * p_n.
  	WRITE: / 'call by value n^2 =', lv_square.
ENDFORM.

" 副程式2：call by reference

FORM sub_ref CHANGING p_n TYPE i.
  	DATA: lv_square TYPE i.
  	lv_square = p_n * p_n.
  	WRITE: / 'call by reference n^2 =', lv_square.
ENDFORM.