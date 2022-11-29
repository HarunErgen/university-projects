import random


def Expression():
    r = random.random()
    if r < 0.15:
        return f"{Expression()} + {Expression()}"
    elif r < 0.30:
        return f"{Expression()} * {Expression()}"
    elif r < 0.45:
        return f"({Expression()})"
    elif r < 0.60:
        return f"({BindingList()}) @ ({Expression()})"
    elif r < 0.75:
        return f"{variable()}"
    else:
        return f"{number()}"


def BindingList():
    r = random.random()
    if r < 0.8:
        return f"{Assignment()} --"
    else:
        return f"{BindingList()} {BindingList()}"


def Assignment():
    return f"'{variable()} := {number()}"
    # return np.random.choice([f"'{variable()} := {number()}", f"'{variable()} := '{variable()}"], p=[0.9, 0.1])


def variable():
    return random.choice(list('abcd'))


def number():
    return str(random.randint(0, 100))


print(Expression())
