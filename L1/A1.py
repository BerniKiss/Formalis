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

# pl (1, 2): a
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

    kimenet.append('digraph G {')
    kimenet.append('    ranksep = 0.5;')
    kimenet.append('    nodesep = 0.5;')
    kimenet.append('    rankdir = LR;')   #  vizsz elrendezes
    kimenet.append('    node [shape = "circle", fontsize = "16"];')
    kimenet.append('    fontsize = "10";')
    kimenet.append('    compound = true;')

    for kezdo in kezdo_lista:
        kimenet.append(f'    i{kezdo} [shape = point, style = invis];')

    # vegallapootoknal dupla kor
    for veg in veg_lista:
        kimenet.append(f'    {veg} [shape = doublecircle];')

    # kezdo allapotok kezelese
    for kezdo in kezdo_lista:
        kimenet.append(f'    i{kezdo} -> {kezdo} [label = start];')

    # atmentek
    for (honnan, hova), szimbolum in atmenet_csoport.items():
        kimenet.append(f'    {honnan} -> {hova} [label = {szimbolum}];')


    kimenet.append('}')

    return '\n'.join(kimenet)


def main():
    bemenet = 'form_I.A.1.txt'
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