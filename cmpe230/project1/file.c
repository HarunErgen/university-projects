#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define SCALAR			0
#define MATRIX			1

typedef struct {
	int row;
	int col;
	double **values;
} Matrix; 

typedef struct {
	int type; // if type == 0, then it is a scalar, if type is 1, then it is a matrix
	union {
		double scalar;
		Matrix matrix;
	} value;
} Variable;

int is_integer(double scalar) {
	return scalar == trunc(scalar);
}

void print_s(double scalar) {
	if (is_integer(scalar))
		printf("%.0f\n", scalar);
	else
		printf("%.7f\n", scalar);
}

Matrix init_matrix(int row, int col) {
	Matrix result;
	result.row = row;
	result.col = col;
	result.values = (double **)malloc(row*sizeof(double *));
	for (int i = 0; i < row; i++) {
		result.values[i] = (double *)malloc(col*sizeof(double));
		for (int j = 0; j < col; j++)
			result.values[i][j] = 0.0;
	}
	return result;
}

Variable init_variable(int type, int row, int col) {
	Variable result;
	if (type == SCALAR) {
		result.type = SCALAR;
		result.value.scalar = 0.0;
	}
	else if (type == MATRIX) {
		result.type = MATRIX;
		result.value.matrix = init_matrix(row, col);
	}
	return result;
}

Variable add(Variable var1, Variable var2) {
	if (var1.type == SCALAR && var2.type == SCALAR) {
		Variable result = init_variable(SCALAR, 0, 0);
		result.value.scalar = var1.value.scalar + var2.value.scalar;
		return result;
	}
	else if (var1.type == MATRIX && var2.type == MATRIX) {
		Variable result = init_variable(MATRIX, var1.value.matrix.row, var1.value.matrix.col);
		for (int i = 0; i < var1.value.matrix.row; i++) {
			for (int j = 0; j < var1.value.matrix.col; j++)
				result.value.matrix.values[i][j] = var1.value.matrix.values[i][j] + var2.value.matrix.values[i][j];
		}
		return result;
	}
}

Variable sub(Variable var1, Variable var2) {
	if (var1.type == SCALAR && var2.type == SCALAR) {
		Variable result = init_variable(SCALAR, 0, 0);
		result.value.scalar = var1.value.scalar - var2.value.scalar;
		return result;
	}
	else if (var1.type == MATRIX && var2.type == MATRIX) {
		Variable result = init_variable(MATRIX, var1.value.matrix.row, var1.value.matrix.col);
		for (int i = 0; i < var1.value.matrix.row; i++) {
			for (int j = 0; j < var1.value.matrix.col; j++)
				result.value.matrix.values[i][j] = var1.value.matrix.values[i][j] - var2.value.matrix.values[i][j];
		}
		return result;
	}
}

Variable multp(Variable var1, Variable var2) {
	if (var1.type == SCALAR && var2.type == SCALAR) {
		Variable result = init_variable(SCALAR, 0, 0);
		result.value.scalar = var1.value.scalar * var2.value.scalar;
		return result;
	}
	else if (var1.type == SCALAR && var2.type == MATRIX) {
		Variable result = init_variable(MATRIX, var2.value.matrix.row, var2.value.matrix.col);
		for (int i = 0; i < var2.value.matrix.row; i++) {
			for (int j = 0; j < var2.value.matrix.col; j++)
				result.value.matrix.values[i][j] = var1.value.scalar * var2.value.matrix.values[i][j];
		}
		return result;
	}
	else if (var1.type == MATRIX && var2.type == SCALAR) {
		Variable result = init_variable(MATRIX, var1.value.matrix.row, var1.value.matrix.col);
		for (int i = 0; i < var1.value.matrix.row; i++) {
			for (int j = 0; j < var1.value.matrix.col; j++)
				result.value.matrix.values[i][j] = var2.value.scalar * var1.value.matrix.values[i][j];
		}
		return result;
	}
	else if (var1.type == MATRIX && var2.type == MATRIX) {
		if (var1.value.matrix.row == 1 && var2.value.matrix.col == 1) {
			Variable result = init_variable(SCALAR, 0, 0);
			for (int k = 0; k < var1.value.matrix.col; k++)
				result.value.scalar += var1.value.matrix.values[0][k] * var2.value.matrix.values[k][0];
			return result;
		}
		Variable result = init_variable(MATRIX, var1.value.matrix.row, var2.value.matrix.col);
		for (int i = 0; i < var1.value.matrix.row; i++) {
			for (int j = 0; j < var2.value.matrix.col; j++) {
				for (int k = 0; k < var1.value.matrix.col; k++)
				result.value.matrix.values[i][j] += var1.value.matrix.values[i][k] * var2.value.matrix.values[k][j];
			}
		}
		return result;
	}
}

void print(Variable var) {
	if (var.type == SCALAR) {
		double scalar = var.value.scalar;
		if (is_integer(scalar))
		printf("%.0f\n", scalar);
	else
		printf("%.7f\n", scalar);
	}
	else if (var.type == MATRIX) {
		for (int i = 0; i < var.value.matrix.row; i++) {
			for (int j = 0; j < var.value.matrix.col; j++)
				print_s(var.value.matrix.values[i][j]);
		}
	}
}
Variable var(double value) {
	Variable result = init_variable(SCALAR, 0, 0);
	result.value.scalar = value;
	return result;
}

Variable tr(Variable var) {
	if (var.type == SCALAR)
		return var;
	else if (var.type == MATRIX) {
		Variable result = init_variable(MATRIX, var.value.matrix.col, var.value.matrix.row);
		for (int i = 0; i < var.value.matrix.row; i++) {
			for (int j = 0; j < var.value.matrix.col; j++)
				result.value.matrix.values[j][i] = var.value.matrix.values[i][j];
		}
	return result;
	}
}

Variable value(Variable var, Variable row, Variable col) {
	double val = (var.type == SCALAR)?var.value.scalar:var.value.matrix.values[(int)row.value.scalar-1][(int)col.value.scalar-1];
	Variable result = init_variable(SCALAR, 0, 0);
	result.value.scalar = val;
	return result; 
}

Variable choose(Variable expr1, Variable expr2, Variable expr3, Variable expr4) {
	if (expr1.value.scalar == 0)		return expr2;
	else if (expr1.value.scalar > 0)    return expr3;
	else 								return expr4;
}
int compare(Variable var1, Variable var2) {
	return (var1.value.scalar <= var2.value.scalar)?1:0;
}

Variable square_root(Variable var) {
	Variable result = init_variable(SCALAR, 0, 0);
	result.value.scalar = sqrt(var.value.scalar);
	return result;
}

int main() {


Variable A = init_variable(MATRIX, 3, 3);
Variable x = init_variable(MATRIX, 3, 1);
Variable y = init_variable(MATRIX, 3, 1);
Variable r = init_variable(SCALAR, 0, 0);
Variable i = init_variable(SCALAR, 0, 0);

A.value.matrix.values[0][0] = 0.5;
A.value.matrix.values[0][1] = 0;
A.value.matrix.values[0][2] = 0.5;
A.value.matrix.values[1][0] = 0;
A.value.matrix.values[1][1] = 0;
A.value.matrix.values[1][2] = 0.5;
A.value.matrix.values[2][0] = 0.5;
A.value.matrix.values[2][1] = 1;
A.value.matrix.values[2][2] = 0;

x.value.matrix.values[0][0] = 1;
x.value.matrix.values[1][0] = 1;
x.value.matrix.values[2][0] = 1;

for (i = var(1); compare(i, var(10)); i = add(i, var(1))) {
	y = multp(A,x);
	r = square_root(multp(tr(sub(y,x)),sub(y,x)));
	// print(tr(sub(y,x)));
	print(r);
	x = y;
}
printf("------------\n");
print(x);


/*
Variable A = init_variable(MATRIX,4,4);
Variable count = init_variable(SCALAR,0,0);
Variable incr = init_variable(SCALAR,0,0);
Variable i = init_variable(SCALAR,0,0);
Variable j = init_variable(SCALAR,0,0);
A.value.matrix.values[0][0] = 0;
A.value.matrix.values[0][1] = 1;
A.value.matrix.values[0][2] = 2;
A.value.matrix.values[0][3] = 3;
A.value.matrix.values[1][0] = 4;
A.value.matrix.values[1][1] = 5;
A.value.matrix.values[1][2] = 6;
A.value.matrix.values[1][3] = 7;
A.value.matrix.values[2][0] = 8;
A.value.matrix.values[2][1] = 9;
A.value.matrix.values[2][2] = 1;
A.value.matrix.values[2][3] = 1;
A.value.matrix.values[3][0] = 1;
A.value.matrix.values[3][1] = 2;
A.value.matrix.values[3][2] = 3;
A.value.matrix.values[3][3] = 4;
count = var(0);
for (i = var(1); compare(i, var(4)); i = add(i, var(1))) {
for (j = var(1); compare(j, var(4)); j = add(j, var(1))) {
incr = choose(sub(value(A,i,j),var(4)),var(1),var(1),var(0));
count = add(count,incr);
}
}
print(count);
*/
return 0;
}
