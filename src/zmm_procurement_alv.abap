*&---------------------------------------------------------------------*
*& Report ZMM_PROCUREMENT_ALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_procurement_alv NO STANDARD PAGE HEADING.

* Project: SAP Procurement Intelligence
* Purpose: Procurement ALV Reporting

PARAMETERS: p_ebeln TYPE ebeln.

TYPES: BEGIN OF ty_purchase_order,
         "ekko
         ebeln TYPE ekko-ebeln, "Purchasing Document Number
         bukrs TYPE ekko-bukrs, "Company Code
         lifnr TYPE ekko-lifnr, "Supplier's Account Number
         "ekpo
         ebelp TYPE ekpo-ebelp, "Item Number of Purchasing Document - Primary Key
         matnr TYPE ekpo-matnr, "Material Number
         werks TYPE ekpo-werks, "Plant
         menge TYPE ekpo-menge, "Purchase Order Quantity
         netpr TYPE ekpo-netpr, "Net Price
         netwr TYPE ekpo-netwr, "Net Order Value
       END OF ty_purchase_order.


TYPE-POOLS: slis. "ALV


DATA: gt_report TYPE TABLE OF ty_purchase_order,
      gs_report TYPE ty_purchase_order,
      gv_count  TYPE i.


DATA: gt_fieldcat TYPE slis_t_fieldcat_alv, "ALV
      gs_fieldcat TYPE slis_fieldcat_alv.


START-OF-SELECTION. "This is where our report's main logic will execute.

  PERFORM get_data.
  PERFORM print_data.
  Perform build_fieldcatalog.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*

FORM get_data .

  "Old abap syntax
**  SELECT a~ebeln a~bukrs a~lifnr
**    b~ebelp b~matnr b~werks b~menge b~netpr b~netwr
**    FROM ekko as a inner join ekpo as b
**    on a~ebeln = b~ebeln
**    into CORRESPONDING FIELDS OF table gt_report
**    where a~ebeln = p_ebeln.

  "New abap syntax
  SELECT a~ebeln, a~bukrs, a~lifnr,
     b~ebelp, b~matnr, b~werks, b~menge, b~netpr, b~netwr
    FROM ekko AS a INNER JOIN ekpo AS b
    ON a~ebeln = b~ebeln
    INTO CORRESPONDING FIELDS OF TABLE @gt_report
    WHERE a~ebeln = @p_ebeln.

  gv_count = lines( gt_report ).

  WRITE:/2 'Purchasing Orders', 22 ': ' , 25 p_ebeln.
  WRITE:/2 'Items Retrieved', 22 ': ' , 25 gv_count.
  WRITE:/2 '------------------------------------------------'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form print_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*

FORM print_data.

"ALV

  IF gt_report IS INITIAL.

    WRITE: / 'No purchasing items found for the selection.'
           COLOR 6 INVERSE ON.

  ELSE.

    PERFORM build_fieldcatalog.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        i_grid_title       = 'Procurement Intelligence ALV Report'
        it_fieldcat        = gt_fieldcat
      TABLES
        t_outtab           = gt_report
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.

    IF sy-subrc <> 0.
      MESSAGE 'ALV display failed' TYPE 'S'
              DISPLAY LIKE 'E'.
    ENDIF.

  ENDIF.

**    IF gt_report[] IS INITIAL. "CLASSICAL
**
**    WRITE: /2 'No purchasing items found for the selection.'
**       COLOR 6 INVERSE ON.
**
**  ELSE.
**
**    LOOP AT gt_report INTO gs_report.
**
**      AT FIRST.
**
**        WRITE:/2 'PO Number' COLOR 7 INVERSE ON, 20 'Company Code' COLOR 7 INVERSE ON, 40 'Supplier Acc-No ' COLOR 7 INVERSE ON,
**        65 'Item Number' COLOR 7 INVERSE ON ,85 'Material Number' COLOR 7 INVERSE ON, 110 'Plant' COLOR 7 INVERSE ON,
**        125 'PO Quantity' COLOR 7 INVERSE ON, 145 'Net Price' COLOR 7 INVERSE ON, 165 'Net Order Value' COLOR 7 INVERSE ON.
**
**        ULINE.
**
**      ENDAT.
**
**      WRITE:/2 gs_report-ebeln LEFT-JUSTIFIED, 20 gs_report-bukrs LEFT-JUSTIFIED, 40 gs_report-lifnr LEFT-JUSTIFIED,
**      65 gs_report-ebelp LEFT-JUSTIFIED, 85 gs_report-matnr LEFT-JUSTIFIED, 110 gs_report-werks LEFT-JUSTIFIED,
**      125 gs_report-menge LEFT-JUSTIFIED, 145 gs_report-netpr LEFT-JUSTIFIED, 165 gs_report-netwr LEFT-JUSTIFIED.
**
**    ENDLOOP.
**
**  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form build_fieldcatalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_fieldcatalog . "ALV

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'EBELN'.
  gs_fieldcat-seltext_m = 'PO Number'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'BUKRS'.
  gs_fieldcat-seltext_m = 'Company Code'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'LIFNR'.
  gs_fieldcat-seltext_m = 'Supplier'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'EBELP'.
  gs_fieldcat-seltext_m = 'Item Number'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'MATNR'.
  gs_fieldcat-seltext_m = 'Material'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'WERKS'.
  gs_fieldcat-seltext_m = 'Plant'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'MENGE'.
  gs_fieldcat-seltext_m = 'PO Quantity'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'NETPR'.
  gs_fieldcat-seltext_m = 'Net Price'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'NETWR'.
  gs_fieldcat-seltext_m = 'Net Order Value'.
  APPEND gs_fieldcat TO gt_fieldcat.

ENDFORM.
