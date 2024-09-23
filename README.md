# ALZ Bicep Accelerator

This repo contains the Azure Landing Zones Bicep Accelerator. For additional information on the Accelerator, please refer to the [Wiki](https://github.com/Azure/ALZ-Bicep/wiki/Accelerator).


# ECIT One Cloud - ALZ Bicep Deployment

## Introduksjon

Dette repositoriet inneholder infrastrukturen og Bicep-skriptene som brukes til å sette opp en **Azure Landing Zone** for kunder i ECIT One Cloud. Dette følger **Microsoft High-Level Deployment Workflow** og er tilpasset til kundeprosjekter ved bruk av Bicep.

## Forutsetninger

Før du starter deployeringsprosessen, sørg for at følgende forutsetninger er oppfylt:

1. **Kundeinformasjon**: Sørg for at du har nødvendig informasjon om kunden, inkludert kundens navn og spesifikke krav for miljøet.
2. De nødvendige **Azure-subscriptionene** har blitt opprettet i **ALSO**:
   - **Management**: Subscription for administrasjon av ressurser og policies.
   - **Connectivity**: Subscription for nettverksressurser (f.eks. Hub).
   - **Corp**: Subscription for interne bedriftsressurser.
   - **Online**: Subscription for eksterne eller offentlige tjenester.
3. En aktiv **Azure-konto**.
4. **Azure CLI** er installert på din lokale maskin. [Installér Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
5. **Bicep CLI** er installert for å kunne kjøre og validere Bicep-skripter. [Installér Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install).
6. Tilgang til **ECIT One Cloud's GitHub-repository**, og evnen til å forke det.
7. Kundenavnet er klart for bruk i opprettelsen av et dedikert fork for prosjektet (f.eks. `kundenavn-10000`).

## Forking av Repository

Før du starter deployeringen, må du forke det opprinnelige repositoriet for å gjøre endringer og tilpasse det til kunden:

1. Gå til det opprinnelige repositoriet: `[ECIT One Cloud Repo URL]`.
2. Klikk på **Fork** øverst til høyre.
3. Velg **Owner** som `ECITSolutionsONEDevelop`.
4. Sett **Repository name** til kundens navn og et unikt ID-nummer, f.eks. `kundenavn-10000`.
5. Skriv inn en beskrivelse hvis ønskelig (f.eks. *ALZ-Bicep-Accelerator*).
6. Forsikre deg om at kun **main**-branchen kopieres.
7. Klikk **Create fork** for å opprette forken.

Når forken er opprettet, klon repositoriet til din lokale maskin:

```bash
git clone https://github.com/ECITSolutionsONEDevelop/kundenavn-10000.git
