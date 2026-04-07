*&---------------------------------------------------------------------*
*& Report ZAB_45_TEST_SCREEN
*&---------------------------------------------------------------------*
REPORT zab_45_test_screen.

DATA: ok_code LIKE sy-ucomm,
      save_ok LIKE ok_code.

" 宣告與 Input/Output field(輸入/輸出欄位) 連結的 Variable(變數)


CALL SCREEN 100.

MODULE user_command_0100 INPUT.
  save_ok = ok_code.
  CLEAR ok_code.

  CASE save_ok.
    WHEN 'C'.
      " 按下 Continue 後，變更 Variable(變數) 的內容
      DATA: input(20) TYPE c.
      input = 'I am back'.
      CALL SCREEN 100.
    WHEN 'E'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.