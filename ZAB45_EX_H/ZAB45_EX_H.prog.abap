*&---------------------------------------------------------------------*
*& Report ZAB45_EX_H
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zab45_ex_h.

TABLES: zab45_emp.

* 讓user輸入部門的ID (多重選取)
SELECT-OPTIONS: s_depid FOR zab45_emp-depid.

DATA: gt_emp TYPE TABLE OF zab45_emp,
      gs_emp TYPE zab45_emp.

START-OF-SELECTION.
  " 根據搜尋條件 (部門ID) 讀取員工資料
  SELECT * FROM zab45_emp
    INTO TABLE gt_emp
    WHERE depid IN s_depid.

  IF sy-subrc = 0.
    " 輸出員工的ID、名字、class、性別、生日
    LOOP AT gt_emp INTO gs_emp.
      WRITE: / gs_emp-emoid,
               gs_emp-name,
               gs_emp-class,
               gs_emp-sex,
               gs_emp-birth.
    ENDLOOP.
  ELSE.
    WRITE: / 'No records found for the given Department ID.'.
  ENDIF.