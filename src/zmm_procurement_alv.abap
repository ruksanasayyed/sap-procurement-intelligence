*&---------------------------------------------------------------------*
*& Report ZMM_PROCUREMENT_ALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmm_procurement_alv NO STANDARD PAGE HEADING.

* Project: SAP Procurement Intelligence
* Purpose: Procurement ALV Reporting

PARAMETERS: p_Ebeln TYPE ebeln.

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

DATA: gt_report TYPE TABLE OF ty_purchase_order,
      gs_report TYPE ty_purchase_order,
      gv_count  TYPE i.

START-OF-SELECTION. "This is where our report's main logic will execute.

  PERFORM get_data.
  PERFORM print_data.

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

FORM print_data .

  IF gt_report[] IS INITIAL.

    WRITE: /2 'No purchasing items found for the selection.'
       COLOR 6 INVERSE ON.

  ELSE.

    LOOP AT gt_report INTO gs_report.

      AT FIRST.

        WRITE:/2 'PO Number' Color 7 INVERSE on, 20 'Company Code' Color 7 INVERSE on, 40 'Supplier Acc-No ' Color 7 INVERSE on,
        65 'Item Number' Color 7 INVERSE on ,85 'Material Number' Color 7 INVERSE on, 110 'Plant' Color 7 INVERSE on,
        125 'PO Quantity' Color 7 INVERSE on, 145 'Net Price' Color 7 INVERSE on, 165 'Net Order Value' Color 7 INVERSE on.

        ULINE.

      ENDAT.

      WRITE:/2 gs_report-ebeln LEFT-JUSTIFIED, 20 gs_report-bukrs LEFT-JUSTIFIED, 40 gs_report-lifnr LEFT-JUSTIFIED,
      65 gs_report-ebelp LEFT-JUSTIFIED, 85 gs_report-matnr LEFT-JUSTIFIED, 110 gs_report-werks LEFT-JUSTIFIED,
      125 gs_report-menge LEFT-JUSTIFIED, 145 gs_report-netpr LEFT-JUSTIFIED, 165 gs_report-netwr LEFT-JUSTIFIED.

    ENDLOOP.

  ENDIF.

ENDFORM.