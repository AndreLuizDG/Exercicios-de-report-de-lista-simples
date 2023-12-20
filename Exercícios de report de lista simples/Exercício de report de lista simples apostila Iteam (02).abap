REPORT z_algj_26.

*--------------------------------------------------------------------*
*2 - Elaborar um programa ABAP onde deverão ser selecionados na tabela EKKO
*os pedidos onde o campo Tipo de Documento de Compras = ‘NB’, retornando os
*campos Número do Documento de Compras, Empresa, Data de criação do registro,
* Numero Fornecedor, Organização de Compras e Grupo de Compradores.
* Para cada pedido encontrado na tabela EKKO selecionar na tabela EKPO apenas
*itens em que o campo Material iniciar por ‘T’, onde o Numero do Documento de Compras
*relaciona as duas tabelas, retornando os campos Numero do Documento de Compras,
*Nº item do documento de compra, Nº do material e Centro. Só imprimir pedidos que
*atendam a esta condição.
* Na impressão do resultado, efetuar uma quebra no relatório por empresa, onde
*deverá ser impresso a quantidade de pedidos encontrada para cada uma das empresas
*selecionadas.
*Imprimir os campos Numero do Documento de Compras, Empresa, Data de
*criação do registro, Numero Fornecedor, Organização de Compras e Grupo de
*Compradores, Nº item do documento de compra, Nº do material e Centro.
*--------------------------------------------------------------------*


* Declarações

TYPES:

  BEGIN OF type_ekko,
    ebeln TYPE ekko-ebeln,
    bukrs TYPE ekko-bukrs,
    bsart TYPE ekko-bsart,
    aedat TYPE ekko-aedat,
    lifnr TYPE ekko-lifnr,
    ekorg TYPE ekko-ekorg,
    ekgrp TYPE ekko-ekgrp,
  END OF type_ekko,

  BEGIN OF type_ekpo,
    ebeln TYPE ekpo-ebeln,
    ebelp TYPE ekpo-ebelp,
    matnr TYPE ekpo-matnr,
    werks TYPE ekpo-werks,
  END OF type_ekpo.

DATA:
  ti_ekko TYPE TABLE OF type_ekko,
  ti_ekpo TYPE TABLE OF type_ekpo.
DATA:
  s_ekko TYPE type_ekko,
  s_ekpo TYPE type_ekpo.
DATA:
  wc_empresa  TYPE type_ekko-bukrs,
  wi_contador TYPE i.

* Eventos
* Forms

* Seleção de dados
FREE ti_ekko.
SELECT ebeln
       bukrs
       bsart
       aedat
       lifnr
       ekorg
       ekgrp
  FROM ekko
  INTO TABLE ti_ekko
 WHERE bsart = 'NB'.

IF sy-subrc <> 0.

  FREE ti_ekko.
  MESSAGE 'Dados de compra não encontrados!' TYPE 'S' DISPLAY LIKE 'E'.

ENDIF.

IF ti_ekko IS NOT INITIAL.

  FREE ti_ekpo.
  SELECT ebeln
         ebelp
         matnr
         werks
    FROM ekpo
    INTO TABLE ti_ekpo
     FOR ALL ENTRIES IN ti_ekko
   WHERE ebeln = ti_ekko-ebeln
     AND matnr LIKE 'T%'.

ENDIF.


SORT: ti_ekko BY ebeln,
      ti_ekpo BY ebeln.

LOOP AT ti_ekko INTO s_ekko.

  READ TABLE ti_ekpo INTO s_ekpo
                     WITH KEY ebeln = s_ekko-ebeln BINARY SEARCH.

*Quebra no relatório por empresa, onde deverá ser impresso a quantidade de pedidos encontrada para cada uma das empresas
*Imprimir os campos
    wi_contador = wi_contador + 1.

  IF wc_empresa NE s_ekko-bukrs.


    FORMAT RESET.

    IF sy-tabix <> 1.
      ULINE.
      WRITE:/ 'EMPRESA: ', wc_empresa.
      WRITE:/ 'TOTAL DE REGISTROS: ', wi_contador.

      CLEAR wi_contador.
    ENDIF.

    wc_empresa = s_ekko-bukrs. " Atualiza a variavel EMPRESA

    FORMAT COLOR COL_HEADING INTENSIFIED ON.
    ULINE.
    WRITE: /01 '|', 'No. DOC COMPRAS',
            20 '|', 'EMPRESA',
            40 '|', 'DATA',
            60 '|', 'No. FORNECEDOR',
            80 '|', 'ORG. COMPRAS',
           100 '|', 'GRUPO COMPRADORES',
           120 '|', 'No. ITEM DOC COMPRAS',
           140 '|', 'No. MATERIAL',
           160 '|', 'CENTRO',
           180 '|'.
    ULINE.

  ENDIF.

  FORMAT RESET.
  WRITE:
         /0 '|',  s_ekko-ebeln, "Numero do Documento de Compras
         20 '|',  s_ekko-bukrs, "Empresa
         40 '|',  s_ekko-aedat, "Data de criação do registro
         60 '|',  s_ekko-lifnr, "Numero Fornecedor
         80 '|',  s_ekko-ekorg, "Organização de Compras
         100 '|', s_ekko-ekgrp, "Grupo de Compradores
         120 '|', s_ekpo-ebelp, "Nº item do documento de compra
         140 '|', s_ekpo-matnr, "Nº do material
         160 '|', s_ekpo-werks, "Centro.
         180 '|'.

ENDLOOP.
