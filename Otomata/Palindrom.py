def is_palindrome_pda(s):
    stack = []
    n = len(s)
    mid = n // 2

    for i in range(mid):
        stack.append(s[i])

    start_pop = mid + 1 if (n % 2 == 1) else mid

    for i in range(start_pop, n):
        if not stack:
            return False
        top = stack.pop()
        if s[i] != top:
            return False

    return len(stack) == 0


if __name__ == "__main__":
    test_strings = [
        "level",
        "madam",
        "kodok",
        "12321",
        "robot",
        "palinilap",
        "abccba",
        "abca"
    ]

    for w in test_strings:
        result = is_palindrome_pda(w)
        print(f"'{w}': {'PALINDROM' if result else 'BUKAN palindrom'}")


