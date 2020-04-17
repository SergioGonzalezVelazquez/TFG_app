export const situations = {
    adelantamiento: {
        level: 5
    },
    estacionamiento: {
        level: 4
    },
    acercamiento: {
        level: 1
    }
};


export function getNextSituation(items: string[]) {
    const nextItem = items.sort((a, b) => situations[a].level < situations[b].level ? -1 : situations[a].level > situations[b].level ? 1 : 0)[0];
    items = items.splice(items.indexOf(nextItem), 1);
    return nextItem;

}
