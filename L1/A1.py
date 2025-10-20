def read_file(fajlnev):
    f = open(fajlnev, 'r')
    sorok = []
    for sor in f:
        sorok.append(sor.strip())
    f.close()
    return sorok

def parse_automata(sorok):
    kezdo_lista = sorok[2].split()
    veg_lista = sorok[3].split()

    atmenet_lista = []
    i = 4
    while i < len(sorok):
        if sorok[i]:
            atmenet_lista.append(sorok[i].split())
        i += 1

    return kezdo_lista, veg_lista, atmenet_lista

def csoportosit_atmenetek(atmenet_lista):
    csoport = {}

    for atmenet in atmenet_lista:
        honnan = atmenet[0]
        szimbolum = atmenet[1]
        hova = atmenet[2]

        par = (honnan, hova)

        if par in csoport:
            csoport[par] = csoport[par] + ', ' + szimbolum
        else:
            csoport[par] = szimbolum

    return csoport

def generate_dot(kezdo_lista, veg_lista, atmenet_csoport):
    kimenet = []
    # egy iranyitott graf
    kimenet.append('digraph finite_state_machine {')
    # vizszintes iranyu elrendezes
    kimenet.append('    rankdir=LR;')
    # grafikon merete
    kimenet.append('    size="8,5"')

    veg_str = ' '.join(veg_lista)
    # vegallapot dupla korrel
    kimenet.append(f'    node [shape = doublecircle]; {veg_str};')
    # osszes allapot amely nem vegallapot sima kor
    kimenet.append('    node [shape = circle];')

    # atmenetek kezelese
    # atmenet_csoport: (1,2): a
    for (honnan, hova), szimbolum in atmenet_csoport.items():
        kimenet.append(f'    {honnan} -> {hova} [label = "{szimbolum}"];')

    # kezdo allapot kezelese
    # init: lathalatlan de innen kezdodik

    for kezdo in kezdo_lista:
        kimenet.append(f'    init -> {kezdo} [label = "start"];')

    kimenet.append('    init [shape = point];')
    kimenet.append('}')

    return '\n'.join(kimenet)

def main():
    bemenet = 'input_A1.txt'
    kimenet = 'output_A1.dot'

    sorok = read_file(bemenet)
    kezdo_lista, veg_lista, atmenet_lista = parse_automata(sorok)
    atmenet_csoport = csoportosit_atmenetek(atmenet_lista)
    dot_tartalom = generate_dot(kezdo_lista, veg_lista, atmenet_csoport)

    f = open(kimenet, 'w')
    f.write(dot_tartalom)
    f.close()
    print("Done! Saved to: ", kimenet)

if __name__ == "__main__":
    main()