from random import randrange


class HashableDict(dict):
    def __hash__(self):
        return hash(tuple(self.items()))


class RobotPlayer:

    def reset_robot_player(self):
        self.known_cards = set()

    def print_cards(self):
        print(self.known_cards)

    def add_cards(self, cards):
        for card in cards:
            self.add_card(card)

    def add_card(self, card):
        hashableCard = HashableDict()
        for key in card:
            hashableCard[key] = card[key]
        self.known_cards.add(hashableCard)

    def calculate_waittime(self, numFaceupCards):
        if numFaceupCards == 2:
            return "1s"

        return "4.5s"

    def _get_pair_index(self, card, cards_facedown):
        for pair_card in self.known_cards:

            if pair_card['classes'] == card['classes']\
              and pair_card['position'] != card['position']:

                for card_ind, card_facedown in enumerate(cards_facedown):
                    if card_facedown['classes'] == pair_card['classes']\
                      and card_facedown['position'] == pair_card['position']:
                        print("_get_pair_index:", pair_card, "index=", card_ind)
                        return card_ind

        print("_get_pair_index:", "not found")
        return -1

    def _is_known_pair(self, card):
        num_known = 0
        for known_card in self.known_cards:
            if known_card['classes'] == card['classes']:
                num_known += 1

        print("_is_known_pair", card)
        return num_known == 2

    def get_card_to_turn(self, cards_facedown, cards_faceup):
        for i, card in enumerate(cards_faceup):
            if self._is_known_pair(card):
                print("get_card_to_turn:", "known pair:", card)
                return self._get_pair_index(card, cards_facedown)

        for i, card in enumerate(cards_facedown):
            if self._is_known_pair(card):
                print("get_card_to_turn:", "pair", i)
                return i

        card_ind = randrange(len(cards_facedown))
        print("get_card_to_turn:", "random=", card_ind)
        return card_ind
