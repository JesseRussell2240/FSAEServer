# GoDaddy Domain Setup

This assumes the domain `conestogaformulaelectric.ca` is registered at GoDaddy and is using GoDaddy nameservers. If the domain is using another DNS provider, make the same records there instead.

## Before You Touch DNS

- Give the Raspberry Pi a reserved LAN address in your router, for example `192.168.1.50`
- Confirm your router can forward TCP `80` and `443` to that Pi
- Find your public IPv4 address from your router or ISP
- Do not use GoDaddy forwarding for this site; use DNS records that point directly at the Pi

## Records To Create

In the GoDaddy DNS panel create or edit these records:

- `A` record, host `@`, value `<your public IPv4>`
- `A` record, host `www`, value `<your public IPv4>`

You can also use a `CNAME` record for `www` pointing to `@`, but matching `A` records is fine and simple.

Do not delete any existing MX records if you later add email.

## GoDaddy UI Path

According to GoDaddy's current help flow, the path is:

1. Sign in to your GoDaddy Domain Portfolio.
2. Select the domain.
3. Open `DNS`.
4. Add or edit the `A` records.

GoDaddy notes that most DNS changes take effect within about an hour, but global propagation can still take up to 48 hours.

## Router Requirements

Forward these ports from the router to the Raspberry Pi:

- TCP `80`
- TCP `443`

Do not forward `22` from the public internet unless you explicitly need remote SSH and have hardened it.

## Dynamic IP Warning

If your home or team internet connection does not have a static public IP, your `A` record may eventually drift. The simple phase-1 approach is manual updates in GoDaddy when the ISP changes the IP. The more durable solution later is:

- a static IP from the ISP, or
- a dynamic DNS updater that can update the GoDaddy `A` record automatically

## Validation

From any machine, verify the records resolve before running Certbot:

```powershell
nslookup conestogaformulaelectric.ca
nslookup www.conestogaformulaelectric.ca
```

Both names should resolve to your current public IP before you request certificates.

## References

- [GoDaddy Manage DNS records](https://www.godaddy.com/help/article/manage-dns-records-680)
- [GoDaddy Add or edit an A record](https://www.godaddy.com/en-in/help/add-or-edit-an-a-record-42546)

