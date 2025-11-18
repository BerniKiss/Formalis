def read_file(path):
    with open(path, 'r') as f:
        lines = f.read().strip().splitlines()

    states = set(lines[0].split(' '))
    terminals = set(lines[1].split(' '))
    initial_state = lines[2].strip()
    accepting_states = set(lines[3].split(' '))

    transitions = {}
    for line in lines[4:]:
        start, symbol, end = line.split(' ')
        transitions[(start, symbol)] = end

    return states, terminals, initial_state, accepting_states, transitions

def compare_dfa(dfa1, dfa2):
    states1, terminals1, start1, accept_states1, transitions1 = dfa1
    states2, terminals2, start2, accept_states2, transitions2 = dfa2


    # ket automata cska akk ekv ha ugyanazzal a szimbolumokkal dolgozik'
    if terminals1 != terminals2:
        return "NO"

    # melysegi bejara'
    # allapotok bejarasa szukseges'
    # stack tart az automata ket kezodo allapotat'
    stack = [(start1, start2)]
    # mely allpotokat hasonlittunk mar ossze'
    visited_pairs = set()

    while stack:
        state1, state2 = stack.pop()

        # egyikbne elfogado masikban nem akk false
        if (state1 in accept_states1) != (state2 in accept_states2):
            return "NO"

        # hozzaadjuk amiot mar feldolgozunk
        visited_pairs.add((state1, state2))

        for symbol in terminals1:
            # ha a stat1 allapotbol a symbolra lepunk akkor hova vezet dfa
            next_state1 = transitions1.get((state1, symbol))
            next_state2 = transitions2.get((state2, symbol))


            # ha mindket automata rendelkezik e atmenettel
            # no ha egyinek van atmente masiknak nincs
            if (next_state1 is None) != (next_state2 is None):
                return "NO"

            # mindket atmente letezik e
            # ha uj allapotpar mar letezik -e a vizitedpairsoibkl
            if next_state1 and next_state2 and (next_state1, next_state2) not in visited_pairs:
                # uj allapotpar hozaadas stackhez
                stack.append((next_state1, next_state2))

    return "YES"

def main():
    dfa1 = read_file('form_I.B.1_a1.txt')
    dfa2 = read_file('form_I.B.1_b2.txt')


    print("Ekvivalensek?", compare_dfa(dfa1, dfa2))

if __name__ == "__main__":
    main()
