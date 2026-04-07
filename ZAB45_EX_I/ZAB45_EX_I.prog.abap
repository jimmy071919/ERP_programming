*&---------------------------------------------------------------------*
*& Report ZAB45_EX_I
*&---------------------------------------------------------------------*
REPORT zab45_ex_i LINE-SIZE 100.

TABLES: zab45_emp.

* 讓user輸入部門的ID (多重選取)
SELECT-OPTIONS: s_depid FOR zab45_emp-depid.

DATA: gt_emp TYPE TABLE OF zab45_emp,
      gs_emp TYPE zab45_emp.

TOP-OF-PAGE.
  WRITE: / 'This is a text header'.
  ULINE.

  FORMAT COLOR COL_HEADING INTENSIFIED ON.
  WRITE: / 'This is a column heading'.
  FORMAT COLOR OFF.
  ULINE.

  SKIP 1.
  WRITE: /28 'A Report Program !!  ^_^' COLOR COL_TOTAL.
  SKIP 1.

  " 表頭欄位
  FORMAT COLOR COL_HEADING INTENSIFIED ON.
  WRITE: /2 'EMP.ID',
          18 'Name',
          40 'Class',
          50 'Sex',
          60 'Birthday'.
  FORMAT COLOR OFF.
  ULINE.

START-OF-SELECTION.
  " 根據搜尋條件 (部門ID) 讀取員工資料
  SELECT * FROM zab45_emp
    INTO TABLE gt_emp
    WHERE depid IN s_depid.

  IF sy-subrc = 0.
    " 輸出員工的ID、名字、class、性別、生日
    LOOP AT gt_emp INTO gs_emp.
      WRITE: /2 gs_emp-emoid,
              18 gs_emp-name,
              40 gs_emp-class,
              50 gs_emp-sex,
              60 gs_emp-birth.
    ENDLOOP.
  ELSE.
    WRITE: /2 'No records found for the given Department ID.'.
  ENDIF.