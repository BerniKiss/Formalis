def read_file(fajlnev):
    with open(fajlnev, 'r') as f:
        sorok = [sor.strip() for sor in f.readlines()]
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

def convert_grammar_to_finite_automaton(non_terminals, terminals, start_symbol, rules):
    transitions = []
    final_states = {"Z"}

    for rule in rules:
        lhs = rule[0]

        if len(rule) == 2:
            rhs = rule[1]
            if rhs in terminals:
                transitions.append((lhs, rhs, "Z"))
            else:
                transitions.append((lhs, rhs, ""))

        elif len(rule) == 1:
            transitions.append((lhs, "epsilon", "Z"))

        elif len(rule) == 3:
            lhs = rule[0]
            rhs = rule[1]
            rhs2 = rule[2]

            if rhs in terminals:
                transitions.append((lhs, rhs, rhs2))
            else:
                transitions.append((lhs, rhs, rhs2))

    return transitions, final_states

def write_to_txt(non_terminals, terminals, start_symbol, transitions, final_states, kimenet_fajl):
    with open(kimenet_fajl, 'w') as f:
        f.write(" ".join(sorted(non_terminals)) + "\n")

        f.write(" ".join(sorted(terminals)) + "\n")

        f.write(start_symbol + "\n")

        f.write(" ".join(sorted(final_states)) + "\n")

        for transition in transitions:
            if transition[2] == "":
                f.write(f"{transition[0]} {transition[1]}\n")
            else:
                f.write(f"{transition[0]} {transition[1]} {transition[2]}\n")

    print(f"Data written to {kimenet_fajl}")

def main():
    input_filename = 'form_I.A.2.txt'
    output_filename = 'automata_2.txt'

    sorok = read_file(input_filename)
    non_terminals, terminals, start_symbol, rules = parse_automata(sorok)

    transitions, final_states = convert_grammar_to_finite_automaton(non_terminals, terminals, start_symbol, rules)
    non_terminals.add("Z")

    write_to_txt(non_terminals, terminals, start_symbol, transitions, final_states, output_filename)
