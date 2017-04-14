	.section	.rodata
.LC0:
	.string	"Hello World"

	.text
main:

	pushq	%rbp
	movq	%rsp, %rbp

	pushq	.LC0(%rip)
	call	printf
	leave
	ret
