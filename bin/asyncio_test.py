import asyncio
import datetime


async def launch_date(date, running_queues):
    for p in running_queues:
        if not running_queues[p].full():
            await running_queues[p].put(date)


async def main():
    # processor -> queue of dates
    running_queues = {}

    limits = {"mahi": 1, "kaula": 1,
              "sunrise": 1, "twilight": 1, "sunset": 1,
              "sundog1": 2, "sundog2": 2, "sundog3": 2}
    for p in limits:
        q = asyncio.Queue(maxsize=limits[p])
        running_queues[p] = q

    date = datetime.date(2021, 5, 26)
    while date < datetime.date.today():
        await launch_date(date, running_queues)
        date += datetime.timedelta(days=1)


if __name__ == "__main__":
    asyncio.run(main())
