def read_file(fajlnev):
    f = open(fajlnev, 'r')
    sorok = []
    for sor in f:
        sorok.append(sor.strip())
    f.close()
    return sorok

def parse_automata(sorok):
    non_terminals = set(sorok[0].split())
    terminals = set(sorok[1].split())
    start_symbol = sorok[2].strip()

    rules = []
    for sor in sorok[3:]:
        parts = sor.split()
        rules.append(parts)

    return non_terminals, terminals, start_symbol, rules

def convert_to_automata(non_terminals, rules):
    # a vegalappot z
    finalS = 'Z'
    new_non_terminals = non_terminals.copy()  # nemterminalisok masol
    new_non_terminals.add(finalS)

    atmenetek = []
    # final_states = {finalS}

    for rule in rules:
        if len(rule) == 3:
            # ha 3 elembol all marad es jo
            fromS = rule[0]
            symbol = rule[1]
            to = rule[2]
            atmenetek.append((fromS, symbol, to))
        elif len(rule) == 2:
            # amikor vegallapotba
            fromS = rule[0]
            symbol = rule[1]
            atmenetek.append((fromS, symbol, finalS))

    return new_non_terminals, atmenetek, finalS


def write_to_txt(non_terminals, terminals, start_symbol, transitions, finalS, kimenet_fajl):
    with open(kimenet_fajl, 'w') as f:
        f.write(" ".join(sorted(non_terminals)) + "\n")

        f.write(" ".join(sorted(terminals)) + "\n")

        f.write(start_symbol + "\n")

        f.write(" ".join(sorted(finalS)) + "\n")

        for transition in transitions:
                f.write(f"{transition[0]} {transition[1]} {transition[2]}\n")
    f.close()
    print(f"Data written into {kimenet_fajl}")

def main():
    input_filename = 'form_I.A.2.txt'
    output_filename = 'out_I.A_2.txt'

    sorok = read_file(input_filename)
    non_terminals, terminals, start_symbol, rules = parse_automata(sorok)

    result = convert_to_automata(non_terminals, rules)
    new_non_terminals = result[0]
    atmenetek = result[1]
    finalS = result[2]

    write_to_txt(new_non_terminals, terminals, start_symbol, atmenetek, finalS, output_filename)


if __name__ == "__main__":
    main()

