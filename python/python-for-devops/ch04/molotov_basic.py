#!/usr/bin/env python
import molotov


@molotov.scenario(weight=60)
async def scenario_one(session):
    async with session.get("http://localhost:5000/") as resp:
        assert resp.status == 200


@molotov.scenario(weight=40)
async def scenario_two(session):
    resp = await session.post("http://localhost:5000", params={"q": "devops"})
    redirect_status = resp.history[0].status
    error = "unexpected redirect status: %s" % redirect_status
    assert redirect_status == 302, error
