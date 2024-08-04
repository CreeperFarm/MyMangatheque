import 'package:flutter/material.dart';

class MentionsLegalesPage extends StatelessWidget {
  const MentionsLegalesPage({super.key});
  
  header(text) {
    return Column(
      children: [
        const Padding(padding: EdgeInsets.only(top: 10)),
        Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
  
  part(text) {
    return Column(
      children: [
        const Padding(padding: EdgeInsets.only(top: 10)),
        SizedBox(
          width: double.infinity,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ]
    );
  }

  subPart(text) {
    return Column(
      children: [
        const Padding(padding: EdgeInsets.only(top: 10)),
        SizedBox(
          width: double.infinity,
          child: Text(
            '      $text',
            style: const TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.justify,
          ),
        )
      ]
    );
  }
  
  paragraph(text) {
    return Column(
      children: [
        const Padding(padding: EdgeInsets.only(top: 10)),
        SizedBox(
          width: double.infinity,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
            ),
            textAlign: TextAlign.justify,
          ),
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentions légales'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              header('MENTIONS LÉGALES'),
              part('Préambule :'),
              paragraph("Les informations et recommandations ( « Informations » ) disponibles sur ce site web ( ou aussi « le Site » ) vous sont proposées en toute bonne foi. Ces informations sont censées être correctes au moment où vous en prenez connaissance. Toutefois, MyMangatheque ou ses filiales et entités affiliées ne sont pas garantes du caractère exhaustif et de l'exactitude des Informations. Vous assumez pleinement les risques liés au crédit que vous leur accordez.",),
              paragraph("Les Informations vous sont fournies à la condition que vous, ou toute autre personne les récent, puissiez déterminer leur intérêt pour un objectif précis avant de les utiliser. En aucun cas, MyMangatheque ou ses filiales et entités affiliées ne seront responsables des dommages susceptibles de résultée du crédit accordé à ces informations, de leur utilisation ou de l'utilisation d'un produit auquel elles font référence."),
              paragraph("Les Informations ne doivent pas être considérées comme des recommandations pour l'utilisation d'informations, de produits, de procédures, d'équipements ou de formulations qui seraient en contradiction avec un brevet, un copyright ou une marque déposée."),
              paragraph("MyMangatheque ou ses filiales et entités affiliées déclineraient toute responsabilité si l'utilisation des Informations venait de contrevenir à un brevet, une marque déposée ou plus généralement un droit de propriété intellectuelle quelconque."),
              paragraph("Aucune garantit, expresse ou implicite, n'est donnée quant à la nature marchande des informations fournies, ni quant à leur adéquation à une finalité déterminée, ainsi qu'en ce qui concerne les produits auxquels il est fait référence dans ces informations."),
              paragraph("En aucun cas, MyMangatheque ou ses filiales et entités affiliées ne s'engagent à mettre à jour ou à corriger les Informations qui seront diffusées par elles sur Internet ou sur leurs serveurs web. De même, MyMangatheque ou ses filiales et entités affiliées se réservent le droit de modifier ou de corriger le contenu de leurs sites à tout moment et sans préavis."),
              part('I - Propriété intellectuelle :'),
              subPart("1 - Droits d'auteurs :"),
              paragraph("MyMangatheque et son contenu (textes, images, vidéos, etc.) sont protégés par les lois sur la propriété intellectuelle en vigueur en France. Toute reproduction, représentation, modification, publication, adaptation de tout ou partie des éléments du site, quel que soit le moyen ou le procédé utilisé, est interdite, sauf autorisation écrite préalable ou à titre personnel comme challenge de code mais sans publication."),
              subPart("2 - Contenu Tiers :"),
              paragraph("Les contenus tiers utilisés sur le site MyMangatheque appartiennent à leurs auteurs respectifs."),
              part('II - Données personnelles :'),
              subPart("1 - Contenu utilisateur :"),
              paragraph("L’Utilisateur est seul responsable du Contenu Utilisateur qu’il met en ligne via le Service, ainsi que des textes et/ou opinions qu’il formule. L'Utilisateur cède expressément et gracieusement à MyMangatheque tout droits de propriété intellectuelle y afférant et notamment le droit de reproduction, de représentation et d'adaptation, pour la durée légale de protection des droits d'auteur. Il s’engage notamment à ce que ces données ne soient pas de nature à porter atteinte aux intérêts légitimes de tiers quels qu’ils soient. À ce titre, il garantit MyMangatheque contre tout recours, fondés directement ou indirectement sur ces propos et/ou données, susceptibles d’être intentés par quiconque à l’encontre de MyMangatheque. Il s’engage en particulier à prendre en charge le paiement des sommes, quelles qu’elles soient, résultant du recours d'un tiers à l'encontre de MyMangatheque, y compris les honoraires d’avocat et frais de justice."),
              paragraph("MyMangatheque se réserve le droit de supprimer tout ou partie du Contenu Utilisateur, à tout moment et pour quelque raison que ce soit, sans avertissement ou justification préalable. L'Utilisateur ne pourra faire valoir aucune réclamation à ce titre."),
              paragraph("MyMangatheque collecte et traite des données personnelles dans le respect de la réglementation en vigueur, notamment du Règlement Général sur la Protection des Données (RGPD)."),
              part("III - Protection des données personnelles :"),
              paragraph("Vos données personnelles sont uniquement destinées à MyMangatheque. Elles ne seront en aucun cas communiquées à des tiers. Au regard des règles de protection des données personnelles (article 34 de Loi « Informatiques et Libertés » du 6 Janvier 1978, directives 95/46 et 97/66), vous disposez d'un droit d'accès, de rectification et de suppression des données qui vous concernent. Pour l'exercer, pour vous opposer à la réception de tout message commercial ou pour toute rectification, adressez-vous par mail, présent dans la rubrique contact."),
              subPart("1 - Utilisation des cookies :"),
              paragraph("L'utilisateur est informé, qu’à l’occasion d’une visite sur le Site, un cookie peut s'installer automatiquement sur son logiciel de navigation. Un cookie consiste en un bloc de données qui ne permet pas d'identifier l'utilisateur mais permet d’enregistrer des informations relatives à la navigation de celui-ci sur le Site afin de procéder à des analyses de fréquentation du Site, le tout pour améliorer la qualité du Site."),
              paragraph("L'utilisateur dispose d'un droit d'accès, de rectification ou de suppression des données personnelles communiquées par le biais d’un cookie dans les conditions indiquées ci-dessus."),
              part("IV - Liens externes :"),
              paragraph("Le site web MyMangatheque peut contenir des liens vers des sites externes. Nous déclinons toute responsabilité quant au contenu et aux pratiques de confidentialité de ces sites. Ces liens sont proposés aux utilisateurs du Site ou des sites web de ses filiales et entités affiliées en tant que service. La décision d'activer les liens appartient exclusivement aux utilisateurs."),
              part("V - Contact, Droit et Date de Mise à Jour :"),
              subPart("1 - Contact :"),
              paragraph("Pour toute question ou réclamation, veuillez nous contacter à l'une des adresses mail suivante : mymangatheque@gmail.com ou contact@mymangatheque.com."),
              subPart("2 - Droit applicable et juridiction compétente :"),
              paragraph("Les présentes mentions légales sont soumises au droit français. En cas de litige, les tribunaux français seront seuls compétents."),
              subPart("Date de dernière mise à jour : Le 13 Décembre 2023")
            ]
          ),
        ),
      ),
    );
  }
}
