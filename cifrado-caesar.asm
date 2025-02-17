.data
mensajeCodificado: .asciz "El mensaje codificado es: "
mensajeDecodificado: .asciz "El mensaje decodificado es: "
seProcesaron1: .asciz "Se procesaron     caracteres "
bienvenida: .asciz "Cifrado CÃ©sar - Â¡Enviando mensajes secretos!"
pregunta: .asciz "Para codificar presione c, de lo contrario para decodificar d"
opcionCodificar: .asciz "Para codificar introduzca: texto;clave;opcion, ejemplo, buen dia;3;2;5;5;3;c"
opcionDecodificar: .asciz "Para decodificar introduzca: texto codificado;clave;opcion, ejemplo jqnb;2;3;5;3;4;d\n o si cuenta con palabra clave es jqnb+bitParidad;hola;d" 
mensajeDesplazamiento: .asciz "El desplazamiento es: "
errorParidad: .asciz "El bit de paridad es incorrecto "
errorClaveLength: .asciz "Introducir un minimo de 5 digitos de clave "
inputUsuario: .asciz "                                                                                                                                                                                     "
mensaje: .asciz "                                                                                                                                                                                            "
conEspacios: .byte 250
claveAsciz: .asciz "                         "
claveLength: .byte 250
opcion: .ascii "   "
enter:.asciz  "\n"
bitParidadInput: .byte 8
sinEspacios: .byte 250
//desplazamiento: .asciz "                "
claveInt: .int
opcionInput: .asciz " "
errorOpcion: .asciz "Ingrese una opcion valida, c o d"

.text
.global main


main:
	mov r0,#0
	bl mostrarEnter
	bl iniciarRegistros
	bl mostrarBienvenida
	bl mostrarEnter
	bl mostrarPregunta
	bl mostrarEnter
	bl leerOpcion
	bl mostrarEnter
	bl cmpOpcion
	bl mostrarEnter
	bl leerInput
	bl extraer_mensaje
	bl guardarMensajeConEspacios
	bl guardarMensajeSinEspacios
	bl extraer_clave
	bl guardarClaveLength
	bl verificarClaveLength
	bl extraer_opcion
	bl iniciarRegistros
	bl verificarOpcion
	bl mostrarMensajeCodificado // muestra Codificado es: +mensaje
	bl mostrarMensajeDecodificado //muestra decodificado es: +mensaje
	bl mostrarMensaje
	bl mostrarEnter
	bl mostrarMensajeDesplazamiento
	bl mostrarDesplazamiento
	bl mostrarCantCaracteres
	bl final


//Bienvenida: muestra el mensaje de bienvenida

mostrarBienvenida:
	.fnstart
	mov r7,#4
	mov r0,#1
	mov r2,#45
	ldr r1,=bienvenida
	swi 0
	bx lr
	.fnend

mostrarPregunta:
	.fnstart
	mov r7,#4
	mov r0,#1
	mov r2,#62
	ldr r1,=pregunta
	swi 0
	bx lr
	.fnend

leerOpcion:
        .fnstart
        mov r7,#3
        mov r0,#0
        mov r2,#2
        ldr r1,=opcionInput
        swi 0
	bx lr
        .fnend

cmpOpcion:
	.fnstart
	push {lr}
	ldr r2,=opcionInput
	ldrb r2,[r2]
	cmp r2,#'c'
	beq mensajeCodificar
	cmp r2,#'C'
	beq mensajeCodificar
	cmp r2,#'d'
	beq mensajeDecodificar
	cmp r2,#'D'
	beq mensajeDecodificar
	bne mensajeErrorOpcion
	.fnend

mensajeCodificar:
	mov r7,#4
	mov r0,#1
	mov r2,#77
	ldr r1,=opcionCodificar
	swi 0
	bal salida

mensajeDecodificar:
	mov r7,#4
	mov r0,#1
	mov r2,#142
	ldr r1,=opcionDecodificar
	swi 0
	bal salida

mensajeErrorOpcion:
	mov r7,#4
	mov r0,#1
	mov r2,#33
	ldr r1,=errorOpcion
	swi 0
	bal final


// extraer_mensaje: el ciclo termina cuando detecta el bit de paridad o el ;

extraer_mensaje:
	.fnstart
	push {lr}
	ldr r0,=mensaje
	bl cicloMensaje
	.fnend

	cicloMensaje:
		ldrb r2,[r1,r3]
		cmp r2,#';'
		beq salida
		cmp r2,#'0'
		beq guardarBitInput
		cmp r2,#'1'
		beq guardarBitInput
		bl contadorMsjeSinEspacios
		strb r2,[r0,r3]
		add r3,#1
		bal cicloMensaje

	contadorMsjeSinEspacios:
		.fnstart
		push {lr}
		cmp r2,#0x20
		beq salida
		add r4,#1
		pop {lr}
		bx lr
		.fnend

guardarBitInput:
	ldr r7,=bitParidadInput
	sub r2,#0x30 //para pasarlo a entero
	strb r2,[r7]
	bal salida

// guardarMensajeLength: dos subrutinas para guardar el mensaje con los espacios contados y sin contar tambien, en diferentes direcciones de memoria

guardarMensajeConEspacios:
	.fnstart
	ldr r2,=conEspacios
	strb r3,[r2]
	bx lr
	.fnend

guardarMensajeSinEspacios:
	.fnstart
	ldr r2,=sinEspacios
	strb r4,[r2]
	bx lr
	.fnend


// extraer_clave; Dependiendo si hubo o no bit de paridad, determino si extraigo una clave numerica o una palabraClave

extraer_clave:
	.fnstart
	push {lr}
	ldr r1,=inputUsuario
	ldr r3,=conEspacios
	ldrb r3,[r3] //ultimaPosicion de desplazamiento inputUsuario
	ldr r4,=claveAsciz
	ldr r0,=bitParidadInput
	ldrb r0,[r0]
	cmp r0,#8
	beq extraerNros //si El bit de paridad es igual a 8, significa que no hubo bit de paridad
	add r3,#1 //para saltear el ; ya que la ultima posicion serÃa la del bit de paridad pero como no la contaba, salto dos posiciones
	bal extraerPalabra // y luego si o si deduzco que entonces va extraerPalabra
	.fnend

	extraerPalabra:
		.fnstart
		add r3,#1 //para saltar el ;
		ldrb r5,[r1,r3]
		cmp r5,#';'
		beq salida //termino si es ;
		strb r5,[r4,r8]
		add r8,#1
		bal extraerPalabra
		.fnend

	extraerNros:
		.fnstart
		add r3,#1
		ldrb r5,[r1,r3]
		cmp r5,#';'
		beq extraerNros
		cmp r5,#'A'  //ACTUALIZACION: el ciclo termina si detecta una letra
		bge salida
		cmp r5,#'d'
		beq salida
		cmp r5,#'C'
                beq salida
                cmp r5,#'D'
                beq salida
		strb r5,[r4,r8] //guarda el nro en r8. A su vez r8 es el contador de la claveLenght
		add r8,#1 // ya que solo se suma 1 al r8 si no cayo en ninguna de las otras comparaciones
		bal extraerNros
		.fnend



//guardarClaveLength

guardarClaveLength:
	.fnstart
	ldr r9,=claveLength
	strb r8, [r9]
	bx lr
	.fnend

//Verificar largo de clave, si o si debe ser minimo de 5 o mas digitos en caso que sea numerica

verificarClaveLength:
        .fnstart
	push {lr}
	ldr r9,=bitParidadInput
	ldrb r9,[r9]
	cmp r9,#8
        bne salida
	cmp r8,#5
        bge salida
        mov r7,#4
        mov r0,#1
        mov r2,#43
        ldr r1,=errorClaveLength
        swi 0
        bal final
        .fnend


//extraer_opcion


extraer_opcion:
	.fnstart
	push {lr}
	ldr r6,=opcion
	cmp r5,#'c'
	beq guardarOpcion
	cmp r5,#'C'
	beq guardarOpcion
	cmp r5,#'d'
	beq guardarOpcion
	cmp r5,#'D'
	beq guardarOpcion
	add r3,#1
	ldrb r5,[r1,r3]
	strb r5,[r6]
	pop {lr}
	bx lr
	.fnend

guardarOpcion:
	.fnstart
	strb r5,[r6]
	bal salida
	.fnend

//VerificarOpcion //comparo si es c o d para determinar si codifico o decodifico, o si no es valida la opcion tira error

verificarOpcion:
	.fnstart
	push {lr}
	ldr r1,=opcion
	ldrb r1,[r1]
	cmp r1,#'c'
	beq codificar
	cmp r1,#'C'
	beq codificar
	cmp r1,#'d'
	beq decodificar
	cmp r1,#'D'
	beq decodificar
	bne mensajeErrorOpcion
	.fnend


//Codificar
codificar:
	bl convertir_ascii_a_entero
        bl cargarRegCodificar
        bl cmpAbcMsje



cargarRegCodificar:
	.fnstart
	mov r2,#0
	mov r4,#4 //lo uso para determinar el largo de la clave ya que voy cargando de a 4 bytes, por lo tanto tengo que multiplicar claveLenght por 4
	ldr r0,=mensaje
	ldr r11,=conEspacios
	ldrb r11,[r11]
	ldr r8,=claveLength
	ldrb r8,[r8]
	ldr r9,=claveInt
	mul r8,r4
	bx lr
	.fnend

cmpAbcMsje: //comparo si debe ingresar en ciclo abcMayus o ciclo abcMinus
	.fnstart
	ldrb r1,[r0,r2]
	cmp r2,r11
	bge salida
	bl saltar_espacio
	cmp r1,#'Z'
	ble cicloAbcMayus
	cmp r1,#'a'
	bge cicloAbcMinus
	.fnend

	cicloAbcMayus:
		ldr r10,[r9,r6] //cargo un entero de la clave
		add r1,r10 //le sumo el desplazamiento
		bl sePasoMayus
		strb r1,[r0,r2]
		add r2,#1
		add r6,#4
		cmp r6,r8
		beq reiniciarClave
		bal cmpAbcMsje

		sePasoMayus:
		.fnstart
		push {lr}
		cmp r1,#'Z'
		ble salida
		sub r1,#26
		pop {lr}
		bx lr
		.fnend


	cicloAbcMinus:
		ldr r10,[r9,r6] //cargo un entero de la clave
		add r1,r10 //le sumo el desplazamiento
		bl sePasoMinus
		strb r1,[r0,r2]
		add r2,#1
		add r6,#4
		cmp r6,r8
		beq reiniciarClave
		bal cmpAbcMsje

		sePasoMinus:
		.fnstart
		push {lr}
		cmp r1,#'z'
		ble salida
		sub r1,#26
		pop {lr}
		bx lr
		.fnend


reiniciarClave:
	mov r6,#0
	bal cmpAbcMsje






//DECODIFICAR

decodificar:
	.fnstart
	push {lr}
	ldr r0,=bitParidadInput
	ldrb r0,[r0]
	cmp r0,#8
	beq pasarClaveAsciz //si no se introdujo bit de paridad, entonces saltero el chequeo de paridad y paso la clave a entero
	ldr r0,=sinEspacios
	ldrb r0,[r0]
	bl calcularParidad
	bl llamadoACalcularDesp //para que despues pueda volver a decodificar
	bl decodificarMensaje
	pop {lr}
	bx lr
	.fnend


pasarClaveAsciz:
	bl convertir_ascii_a_entero
	bl decodificarMensaje
	bal salida

calcularParidad:
	.fnstart
	sub r0,#2
	cmp r0,#2
	bge calcularParidad
	ldr r1,=bitParidadInput
	ldrb r1,[r1]
	cmp r0,r1  //verifico que la paridad sea correcta
	bne bitErrorMsje
	bx lr //si sale es que la paridad era correcta
	.fnend

	bitErrorMsje:
        .fnstart
        bl mostrarEnter
        mov r7,#4
        mov r0,#1
        mov r2,#33
        ldr r1,=errorParidad
        swi 0
        bal final
        .fnend


llamadoACalcularDesp:
	.fnstart
	push {lr}
	mov r12,#4
	ldr r0,=mensaje
	mov r2,#0
        ldr r4,=claveAsciz
        ldr r6,=claveLength
	ldrb r6,[r6]
	mul r6,r12
	mov r9,#26
        ldr r10,=claveInt
	mov r12,#0
	bal calcularDesplazamiento
	.fnend


//calcularDesplazamiento

calcularDesplazamiento:
	.fnstart
	ldrb r1,[r0,r2]// cargo letra de msje
	bl saltar_espacio
	bl cmpMayusMinus //me fijo si debe estar en mayus o minus para que de el desplazamiento correcto
	.fnend
cmpMayusMinus:
	.fnstart
	cmp r1,#'Z'
	ble despMayus
	cmp r1,#'a'
	bge despMinus
	.fnend


	despMayus: //verifico que la letra este en mayus o minus segun corresponda segun el msje
		ldrb r5,[r4,r12] //cargo letra de clave
		bl pasarAMayus //si esta en minuscula lo paso a mayus para que me de el desplazamiento correcto
		subs r8,r1,r5 // resto letra msje menos letra de clave, eso me da el desplazamiento en entero
		bl despNegativo //es por si da menor que cero
		str r8,[r10,r3] //lo guardo en etiqueta claveInt
		add r8,#0x30
		strb r8,[r4,r12] //lo guardo en claveAsciz
		add r3,#4
		cmp r3,r6
		beq salida //termino de "agarrar" la clave
		add r12,#1
		add r2,#1
		mov r8,#0
		bal calcularDesplazamiento

		pasarAMayus:
		.fnstart
		push {lr}
		cmp r5,#'Z'
		ble salida // si es menor que Z, se asume que esta dentro de las mayus y sale
		sub r5,#0x20 //sino le resto a r5 20hexa para pasar a mayus
		pop {lr}
		bx lr
		.fnend

	despMinus:
		ldrb r5,[r4,r12]
		bl pasarAMinus
		subs r8,r1,r5
		bl despNegativo
		str r8,[r10,r3]
		add r8,#0x30
		strb r8,[r4,r12]
		add r3,#4
		cmp r3,r6
		beq salida
		add r12,#1
		add r2,#1
		mov r8,#0
		bal calcularDesplazamiento

		pasarAMinus:
	        .fnstart
       		push {lr}
	        cmp r5,#'a'
        	bge salida
	       	add r5,#0x20
        	pop {lr}
       		bx lr
	        .fnend


despNegativo:
	.fnstart
	push {lr}
	cmp r8,#0
	bge salida
	mov r8,#0
	sub r5,r1 //hago la resta al reves para que me de positivo
	sub r8,r9,r5 //resto en r8 la cant de letras del abecedario menos lo que me dio la resta al reves, me da el desplazamiento correcto 
	pop {lr}
	bx lr
	.fnend


//Decodificar Mensaje

decodificarMensaje:
	.fnstart
	push {lr}
	mov r12,#4
	ldr r0,=mensaje
	mov r2,#0
	mov r3,#0
	ldr r10,=claveInt
	ldr r8,=conEspacios
	ldrb r8,[r8]
	ldr r6,=claveLength
	ldrb r6,[r6]
	mul r6,r12
	bal aplicarCicloDec
	.fnend


aplicarCicloDec:
	.fnstart
	cmp r2,r8
	bge salida
	ldrb r1,[r0,r2] //cargo letra de msje
	bl saltar_espacio
	cmp r2,r8
	bge salida
	cmp r1,#'Z'
	ble cicloMayusDec
	cmp r1,#'a'
	bge cicloMinusDec
	.fnend


	cicloMayusDec:
		.fnstart
		ldr r5,[r10,r3] //cargo digito de desplazamiento
		sub r1,r5 //le resto el desplazamiento
		bl sePasaNegMayus //comprueba si se pasa
		strb r1,[r0,r2] //guardo en r0 el ascii desplazado
		add r2,#1
		add r3,#4
		cmp r3,r6
		beq reiniciarDesp
		bal aplicarCicloDec
		.fnend

		sePasaNegMayus:
	        .fnstart
        	push {lr}
        	cmp r1,#'A'
	        bge salida
	        add r1,#26 //tamaÃ±o abecedario, agregandole 26 se devuelve a la posicion correcta de abcdario en mayuscula
	        pop {lr}
	        bx lr
        	.fnend




	cicloMinusDec:
		.fnstart
	       	ldr r5,[r10,r3] //cargo digito de desplazamiento
	       	sub r1,r5 //le resto el desplazamiento
	        bl sePasaNegMinus //comprueba si se pasa
	        strb r1,[r0,r2] //guardo en r0 el ascii desplazado
	        add r2,#1
	        add r3,#4
       		cmp r3,r6
        	beq reiniciarDesp
	        bal aplicarCicloDec
       		.fnend

		sePasaNegMinus:
		.fnstart
		push {lr}
		cmp r1,#'a'
		bge salida
		add r1,#26
		pop {lr}
		bx lr
		.fnend

reiniciarDesp: //reinicia la clave del desplazamiento
	mov r3,#0
	bal aplicarCicloDec



//Mostrar Mensaje Codificado

mostrarMensajeCodificado:
	.fnstart
	push {lr}
	ldr r0,=opcion
	ldrb r0,[r0]
	cmp r0,#'d'
	beq salida
	cmp r0,#'D'
	beq salida
	mov r7,#4
	mov r0,#0
	mov r2,#27
	ldr r1,=mensajeCodificado
	swi 0
	pop {lr}
	bx lr
	.fnend

//Mostrar Mensaje decodificado

mostrarMensajeDecodificado:
        .fnstart
        push {lr}
        ldr r0,=opcion
        ldrb r0,[r0]
        cmp r0,#'c'
        beq salida
	cmp r0,#'C'
	beq salida
        mov r7,#4
        mov r0,#0
        mov r2,#29
        ldr r1,=mensajeDecodificado
        swi 0
        pop {lr}
        bx lr
        .fnend


//Mostar Mensaje

mostrarMensaje:
	.fnstart
	push {lr}
	ldr r11,=conEspacios
	ldrb r11,[r11]
	add r11,#1 // porque esta en asciz
        mov r7,#4
        mov r0,#0
        mov r2,r11
        ldr r1,=mensaje
        swi 0
	pop {lr}
	bx lr
	.fnend

//Mostrar caracteres procesados

mostrarCantCaracteres:
        .fnstart
        push {lr}
        ldr r0,=opcion
        ldrb r0,[r0]
        cmp r0,#'d'
        beq salida
	cmp r0,#'D'
	beq salida
	ldr r1,=seProcesaron1
	mov r4,#0
	mov r8,#15
	mov r6,#0
	mov r9,#0
	ldr r3,=sinEspacios
	ldrb r3,[r3]
        bl entero_a_ascii

        mov r7,#4
        mov r0,#0
        mov r2,#30
        ldr r1,=seProcesaron1
        swi 0
	bal salida
        .fnend

final:
	bl mostrarEnter
	mov r7,#1
	swi 0





//MostrarDesplazamiento



mostrarMensajeDesplazamiento:
        .fnstart
        push {lr}
        ldr r0,=opcion
        ldrb r0,[r0]
        cmp r0,#'c'
        beq salida
	cmp r0,#'C'
	beq salida
	mov r7,#4
	mov r0,#0
	mov r2,#23
	ldr r1,=mensajeDesplazamiento
	swi 0
	bal salida
	.fnend

mostrarDesplazamiento:
	.fnstart
	push {lr}
	ldr r0,=opcion
	ldrb r0,[r0]
	cmp r0,#'c'
	beq salida
	cmp r0,#'C'
	beq salida
	ldr r0,=claveLength
        ldrb r11,[r0]
        mov r7,#4
        mov r0,#0
        mov r2,r11
        ldr r1,=claveAsciz
        swi 0
        bal salida
        .fnend






// SUBRUTINAS SECUNDARIAS


//convertir ascii a entero, para pasar la clave asciz a clave int


convertir_ascii_a_entero:
        .fnstart
        push {lr}
        ldr r0,=claveAsciz
        ldr r8,=claveLength
        ldrb r8,[r8]
        ldr r9,=claveInt
        mov r2,#0
        mov r7,#0
        bal cicloConvertir
        .fnend

        cicloConvertir:
        ldrb r1,[r0,r2]
        sub r1,#0x30
        str r1,[r9,r7]
        add r7,#4
        add r2,#1
        cmp r2,r8
        beq salida
        bal cicloConvertir


//Pasar de entero a Ascii

entero_a_ascii:
	.fnstart
	push {lr}
	cmp r3,#9
	ble sumar30
	cmp r3,#99
	ble division10
	bal salida
	bx lr
	.fnend


	division10:
	cmp r3,#10
        blt conversion
        sub  r3, #10 //en r3 se guarda el resto
        add r6,#1 //contador de divisiones
        bal division10

        conversion:
        add r6,#0x30
        strb r6,[r1,r8]
        add r3,#0x30
        add r8,#1
        strb r3,[r1,r8]
        bal salida

	sumar30:
	add r3,#0x30
	strb r3,[r1,r8]
       	bal salida



//Saltar espacio: saltea el espacio de donde se este ejecutando una subrutina que lee caracteres ascii
saltar_espacio:
	.fnstart
	push {lr}
	bal cicloEspacio
	.fnend

	cicloEspacio:
	.fnstart
	cmp r1,#0x20
	bne salida
	add r2,#1
	ldrb r1,[r0,r2]
	bal cicloEspacio
	.fnend

//Salia: simplemente "popea" el link register. Se usa mucho para realizar comparaciones y volver al main para continuar con otra subrutina
	// siempre y cuando este el push {lr} correspondiente

salida:
	.fnstart
	pop {lr}
	bx lr
	.fnend

//Muestra un enter en pantalla

mostrarEnter:
	.fnstart
	push {lr}
	mov r7,#4
	mov r0,#0
	mov r2,#2
	ldr r1,=enter
	swi 0
	pop {lr}
	bx lr
	.fnend

//Inicar registros del 0 al 12 en 0

iniciarRegistros:
	.fnstart
	mov r0,#0
	mov r1,#0
	mov r2,#0
	mov r3,#0
	mov r4,#0
	mov r5,#0
	mov r6,#0
	mov r7,#0
	mov r8,#0
	mov r9,#0
	mov r10,#0
	mov r11,#0
	mov r12,#0
	bx lr
	.fnend

//Lee el input introducido por el usuario

leerInput:
	.fnstart
	mov r7,#3
	mov r0,#0
	mov r2,#500
	ldr r1, =inputUsuario
	swi 0
	bx lr
	.fnend
